function readAllData(obj)

SECONDS_IN_DAY  = obj.options.SECONDS_IN_DAY;
DATE_CONV_FACTOR = obj.options.DATE_CONV_FACTOR;
UTC_DIFF        = obj.options.utc_diff;
STRING_ENCODING = obj.options.STRING_ENCODING;

fid = obj.file_fid;
n_segs = obj.meta.n_segs;
segs = obj.meta.segs;
chans = obj.meta.chans;

n_objects = obj.meta.n_chans;
cur_file_index  = zeros(1,n_objects); %current # of samples read from file
cur_data_index  = zeros(1,n_objects); %current # of samples assigned to output
data = cell(1,n_objects);  %a pointer for each channel
data_type_array = [chans.data_type];
n_values_total_per_channel = [chans.n_values_total];
n_values_total_per_channel(n_objects+1:end) = [];

for i = 1:n_objects
    if chans(i).n_values_total > 0
        data{i} = chans(i).getInitializedData();
    end
end

%
keep_data_array = true(1,n_objects);

[precision_type, n_bytes] = tdms.utils.TDMS_getTypeSeekSizes;

%Get end of file position, seek back to beginning
fseek(fid,0,1);
eofPosition = ftell(fid);
fseek(fid,0,-1);

for iSeg = 1:n_segs
    seg = segs(iSeg);
    %Seek to this raw position, this is needed to avoid meta data
    fseek(fid,seg.data_start_position,'bof');
    
    n_chunks = seg.n_chunks;
    for iChunk = 1:n_chunks
        %------------------------------------------------------------------
        %Interleaved data processing
        %------------------------------------------------------------------
        if seg.is_interleaved
            obj_order = seg.obj_order;
            data_types = data_type_array(obj_order);
            
            n_read = seg.n_samples_read;
            
            %error checking
            if any(data_types ~= data_types(1))
                error('Interleaved data is assumed to be all of the same type')
            end
            
            if any(n_read ~= n_read(1))
                error('# of values to read are not all the same')
            end
            
            %NOTE: unlike below, these are arrays that we are working with
            startI = cur_file_index(obj_order) + 1;
            endI   = cur_file_index(obj_order) + n_read(1);
            cur_file_index(obj_order) = endI;
            cur_data_index(obj_order) = endI;
            
            nChans        = length(obj_order);
            numValuesRead = n_read(1);
            switch data_types(1)
                case {1 2 3 4 5 6 7 8 9 10}
                    temp = fread(fid,numValuesRead*nChans,precision_type{data_types(1)});
                case 32
                    error('Unexpected interleaved string data')
                    %In Labview 2009, the interleaved input is ignored
                    %Not sure about other versions
                case 33
                    %This never seems to be called, shows up as uint8 :/
                    temp = logical(fread(fid,numValuesRead*nChans,'uint8'));
                case 68
                    temp = fread(fid,numValuesRead*2*nChans,'*uint64');
                    temp = (double(temp(1:2:end))/2^64 + double(typecast(temp(2:2:end),'int64')))...
                        /SECONDS_IN_DAY + DATE_CONV_FACTOR + UTC_DIFF/24;
                case 524300
                    temp = fread(fid,2*numValuesRead*nChans,'*single');
                    temp = complex(temp(1:2:end),temp(2:2:end));
                case 1048589
                    temp = fread(fid,2*numValuesRead*nChans,'*double');
                    temp = complex(temp(1:2:end),temp(2:2:end));
                otherwise
                    error('Unexpected data type: %d',data_types(1))
                    
            end
            
            %NOTE: When reshaping for interleaved, we must put nChans as
            %the rows, as that is the major indexing direction, we then
            %grab across columns
            %Channel 1 2 3 1  2  3
            %Data    1 2 3 11 22 33 becomes:
            %   1 11
            %   2 22    We can now grab rows to get individual channels
            %   3 33
            temp = reshape(temp,[nChans numValuesRead]);
            for iChan = 1:nChans
                if keep_data_array(obj_order(iChan))
                    data{obj_order(iChan)}(startI(iChan):endI(iChan)) = temp(iChan,:);
                end
            end
            
        else
            
            %--------------------------------------------------------------
            %NOT INTERLEAVED
            %--------------------------------------------------------------
            for iObjList = 1:length(seg.obj_order)
                I_object = seg.obj_order(iObjList);
                
                n_values_available = seg.n_samples_read(iObjList);
                data_type = data_type_array(I_object);
                
                cur_file_index(I_object) = cur_file_index(I_object) + n_values_available;
                
                %Actual reading of data (or seeking past)
                %------------------------------------------
                if ~keep_data_array(I_object)
                    if data_type == 32
                        %I don't think we need the data type check if we
                        %use this ...
                        n_string_bytes = total_bytes_arrray(I_object);
                        fseek(fid,n_string_bytes,'cof');
                    else
                        fseek(fid,n_values_available*n_bytes(data_type),'cof');
                    end
                else
                    startI = cur_data_index(I_object) + 1;
                    endI   = cur_data_index(I_object) + n_values_available;
                    cur_data_index(I_object) = endI;
                    switch data_type
                        case {1 2 3 4 5 6 7 8 9 10}
                            data{I_object}(startI:endI) = fread(fid,n_values_available,precision_type{data_type});
                        case 32
                            %Done above now ...
                            strOffsetArray = [0; fread(fid,n_values_available,'uint32')];
                            offsetString = startI - 1;
                            for iString = 1:n_values_available
                                offsetString = offsetString + 1;
                                temp = fread(fid,strOffsetArray(iString+1)-strOffsetArray(iString),'*uint8');
                                data{I_object}{offsetString}  = native2unicode(temp,STRING_ENCODING)'; %#ok<*N2UNI>
                            end
                            %NOTE: Even when using a subset, we
                            %will only ever have one valid read
                        case 33
                            data{I_object}(startI:endI)   = logical(fread(fid,n_values_available,'uint8'));
                        case 68
                            temp = fread(fid,n_values_available*2,'*uint64');
                            %First row: conversion to seconds
                            %Second row: conversion to days, and changing of reference frame
                            data{I_object}(startI:endI) = (double(temp(1:2:end))/2^64 + double(typecast(temp(2:2:end),'int64')))...
                                /SECONDS_IN_DAY + DATE_CONV_FACTOR + UTC_DIFF/24;
                        case 524300
                            temp = fread(fid,2*n_values_available,'*single');
                            data{I_object}(startI:endI) = complex(temp(1:2:end),temp(2:2:end));
                        case 1048589
                            temp = fread(fid,2*n_values_available,'*double');
                            data{I_object}(startI:endI) = complex(temp(1:2:end),temp(2:2:end));
                        otherwise
                            error('Unexpected type: %d', data_type)
                    end
                end
            end
        end
    end
    
    
    %Some error checking just in case
    if iSeg ~= n_segs
        Ttag = fread(fid,1,'uint8');
        Dtag = fread(fid,1,'uint8');
        Stag = fread(fid,1,'uint8');
        mtag = fread(fid,1,'uint8');
        if ~(Ttag == 84 && Dtag == 68 && Stag == 83 && mtag == 109)
            error('Catastrophic error detected, code probably has an error somewhere')
        end
    else
        if eofPosition ~= ftell(fid) && ~metaStruct.eof_error
            error('Catastrophic error detected, code probably has an error somewhere')
        end
    end
end

%ERROR CHECKING ON # OF VALUES READ
%==========================================================================
if ~isequal(n_values_total_per_channel,cur_data_index)
    error('The # of requested values does not equal the # of returned values, error in code likely')
end

%END OF READING RAW DATA
%==========================================================================
%fclose(fid);


end
