classdef meta_chan_info < handle
    %
    %   Class:
    %   tdms.meta_chan_info
    %
    %   See Also
    %   --------
    %   tdms.meta_chans_info
    
    properties
        %Whether object has raw_daq_mx data
        
        name
        chan_name
        grou_name
        
        index
        
        info_set = false
        
        is_raw_daq_mx = false
        
        %This is how many bytes the entry occupies in a meta data section
        length_of_index
        
        %This is currently only 1
        n_dimensions
        
        %enumerated dataType (Labview)
        
        %Jim's value of -1
        %Need to make sure that concatenating doesn't drop channels
        %[chans.data_type] - problematic if any are empty
        data_type = -1
        n_values_per_read = 0
        
        %This is derived from data_type & # of values per read.
        %For strings, this is a specific value specified in the file.
        n_bytes_per_read
        
        
        has_raw_data = false
        
        
        n_values_total = 0
        
        n_properties = 0
        prop_names
        prop_values
        
        %
        chunk_index = 0
        
        %Column 1, file position
        %Column 2, first sample at that position
        %Column 3, segment number
        data_matrix
        
        
    end
    
    methods (Static)
        function objs = initialize(options)
            %
            %   objs = tdms.meta_chan_info.initialize(options)
            %
            %   Inputs
            %   ------
            %   options: tdms.options
            
            n = options.n_objects_guess;
            n_props = options.n_max_props_guess;
            objs(1,n) = tdms.meta_chan_info();
            for i = 1:n
                objs(i).index = i;
                objs(i).prop_names = cell(1,n_props);
                objs(i).prop_values = cell(1,n_props);
            end
        end
        function objs = grow(objs,options)
            n1 = length(objs);
            n = n1 + options.n_objects_guess;
            n_props = options.n_max_props_guess;
            objs(1,n) = tdms.meta_chan_info();
            for i = (n1+1):n
                objs(i).index = i;
                objs(i).prop_names = cell(1,n_props);
                objs(i).prop_values = cell(1,n_props);
            end
        end
    end
    methods
        function chunk_byte_offset = updateChunkInfo(obj,seg,chunk_byte_offset)
            INIT_CHUNK_SIZE = 1000;
            
            n_samples_read = obj.n_values_per_read;
            n_chunks = seg.n_chunks;
            n_bytes_per_chunk = seg.n_bytes_per_chunk;
            
            if n_samples_read > 0
                %This allows us to grow these values if we haven't sufficiently preallocated
                if obj.chunk_index + n_chunks > size(obj.data_matrix,1)
                    obj.data_matrix = [obj.data_matrix; zeros(INIT_CHUNK_SIZE,3)];
                end
                
                %data_matrix:
                %==============================================================
                %This information is used for reading parts of an object during
                %a single read instead of the entire object
                
                %Column 1, file position
                indices = (obj.chunk_index+1):(obj.chunk_index+n_chunks);
                start_byte = seg.data_start_position + chunk_byte_offset;
                stop_byte = (n_chunks-1)*n_bytes_per_chunk;
                obj.data_matrix(indices,1) = ...
                    start_byte + (0:n_bytes_per_chunk:stop_byte);
                
                %Column 2, first sample at that position
                stop_value = (n_chunks-1)*obj.n_values_per_read + 1;
                obj.data_matrix(indices,2) = ...
                    obj.n_values_total + (1:n_samples_read:stop_value);
                
                %Column 3, segment number
                obj.data_matrix(indices,3) = seg.index;
                
                %For each channel, we want to document where its
                %bytes start per chunk. As we progress to subsequent
                %channels in the chunk we need to adjust the offset
                %by the # of bytes we read in the previous
                %xxxx     xxxx     xxxx         <= start at 0
                %    yyy      yyy      yyy      <= start at 4 (4 bytes of x)
                %       zz       zz       zz    <= start at 7 (4 + 3 of y)
                %
                %
                
                
                chunk_byte_offset = chunk_byte_offset + obj.n_bytes_per_read;
                obj.n_values_total = obj.n_values_total + n_samples_read*n_chunks;
                obj.chunk_index = obj.chunk_index + n_chunks;
            end
        end
        function output = getInitializedData(obj,n_values)
            if nargin < 2
                n_values = obj.n_values_total;
            end
            output = TDMS_initData(obj.data_type,n_values);
        end
        function setOrUpdate(obj,fid,DEBUG)
            curPos = ftell(fid);
            
            raw_data_index_length = fread(fid,1,'uint32');
            
            obj.length_of_index = raw_data_index_length;
            
            if DEBUG
                fprintf(2,'RawDataLength: %d\n',raw_data_index_length);
                fprintf(2,'CurrentPos: %d\n',curPos);
            end
            
            switch raw_data_index_length
                case 0 %Same as previous
                    if obj.info_set == false
                        error(['Channel %s set to use previous rawDataIndex'
                            ' but this channel is new'],object_name)
                    end
                    
                    %QUIRK
                    %NOTE: "same as previous segment" apparently means
                    %"same as the previous one with data ..."
                    %
                    %   JAH: 3/5/2022 - this code doesn't do that ...
                    
                    obj.has_raw_data = obj.n_values_per_read > 0;
                case 2^32-1 %no raw data
                    %obj.info_set = true;
                    obj.has_raw_data = false;
                otherwise
                    obj.has_raw_data = true;
                    
                    %DATA TYPE HANDLING
                    %------------------------------------------------------
                    data_type_local = fread(fid,1,'uint32');
                    if obj.info_set && (data_type_local ~= obj.data_type) ...
                            && obj.n_values_total > 0
                        error('Raw data type for channel %s has changed from %d to %d',...
                            object_name, obj.data_type, data_type_local)
                    else
                        obj.data_type = data_type_local;
                    end
                    
                    %DATA SIZE HANDLING
                    %-----------------------------------------------------
                    obj.n_dimensions  = fread(fid,1,'uint32');
                    if obj.n_dimensions ~= 1
                        error('Code doesn''t yet handle non 1D data')
                    end
                    
                    obj.n_values_per_read = fread(fid,1,'uint64');
                    
                    obj.info_set = true;
                    
                    
                    %RawDaqMX
                    %------------------------------------------------------
                    %NOTES:
                    if data_type_local == 2^32-1
                        obj.handleRawDAQMxData();
                    else %Non RawDAQmx type
                        if obj.data_type == 32
                            %If string, size is specified by an additional field
                            obj.n_bytes_per_read = fread(fid,1,'uint64');
                        else
                            obj.n_bytes_per_read = ...
                                obj.n_values_per_read*TDMS_getDataSize(data_type_local);
                        end
                        
                        %Another chance to check correct reading
                        if curPos + obj.length_of_index ~= ftell(fid)
                            error(['Raw Data Index length was incorrect: %d stated vs %d observed,' ...
                                'likely indicates bad code or a bad tdms file'],...
                                obj.length_of_index,ftell(fid) - curPos)
                        end
                    end
                    
                    if DEBUG
                        fprintf(2,'nSegs: %d\n',n_segs);
                        fprintf(2,'objName: %s\n',object_name);
                    end
            end
            
            
        end
        function handleRawDAQMxData(obj)
            %JIM CODE IN PROGRESS
            obj.is_raw_daq_mx = true; %We can
            % % %                         %post process this to convert from bits to an
            % % %                         %actual value
            % % %
            % % %                         %FORMAT:
            % % %                         %1) -
            % % %                         daqMXVersion = rawDataIndexLength;
            % % %                         if ~ismember(daqMXVersion,[4713 4714])
            % % %                             error('Unexpected version: %d',daqMXVersion)
            % % %                         end
            % % %
            % % %
            % % %                         %2) Let's get the remaining # of bytes
            % % %                         %This seems to be 32 ...
            % % %
            % % % % %                         wtf = fread(fid,8,'uint32');
            % % % % %                         disp(wtf)
            % % %                         %4713
            % % %                         %13000012
            % % %                         %15000018
            % % %                         %? -> 8th indicates data type? OR -> bytes per sample
            % % %
            % % %                         %4714
            % % %                         %1 0 0 0 256 256 512
            % % %
            % % %                         %3) Update datetype - where the heck is it?
            % % %                         %rawDataInfo(objIndex).dataType = dataType;
        end
        function updateProps(obj,fid)
            STRING_ENCODING = 'UTF-8';
            
            %PROPERTY HANDLING
            %--------------------------------------------------------------
            numberProperties = fread(fid,1,'uint32');
            %Below is the # of props already assigned to that channel
            nPropsChan       = obj.n_properties;
            
            for iProp = 1:numberProperties
                propNameLength  = fread(fid,1,'uint32');
                temp            = fread(fid,propNameLength,'*uint8');
                propName        = native2unicode(temp,STRING_ENCODING)';
                propDataType    = fread(fid,1,'uint32');
                
                propIndex = find(strcmp(obj.prop_names(1:nPropsChan),propName),1);
                if isempty(propIndex)
                    %Updates needed for new properties
                    nPropsChan              = nPropsChan + 1;
                    propIndex               = nPropsChan;
                    obj.prop_names{propIndex} = propName;
                end
                
                %Update value
                propValue = TDMS_getPropValue(fid,propDataType);
                obj.prop_values{propIndex} = propValue;
            end
            obj.n_properties = nPropsChan;
        end
    end
end

function propValue = TDMS_getPropValue(fid,propDataType)
%TDMS_getPropValue  Returns the property value given the Labview DataType
%
%   propValue = TDMS_getPropValue(fid,propDataType,UTC_DIFF)
%
%   See Also: TDMS_getDataTypeName

UTC_DIFF        = -5;
DATE_STR_FORMAT = 'dd-mmm-yyyy HH:MM:SS:FFF';
SECONDS_IN_DAY  = 86400;
CONV_FACTOR     = 695422; %datenum('01-Jan-1904')
UNICODE_FORMAT  = 'UTF-8';

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
switch propDataType
    case 1
        propValue    = fread(fid,1,'*int8');
    case 2
        propValue    = fread(fid,1,'*int16');
    case 3
        propValue    = fread(fid,1,'*int32');
    case 4
        propValue    = fread(fid,1,'*int64');
    case 5
        propValue    = fread(fid,1,'*uint8');
    case 6
        propValue    = fread(fid,1,'*uint16');
    case 7
        propValue    = fread(fid,1,'*uint32');
    case 8
        propValue    = fread(fid,1,'*uint64');
    case 9
        propValue    = fread(fid,1,'*single');
    case 10
        propValue    = fread(fid,1,'*double');
    case 25
        propValue    = fread(fid,1,'*single');
    case 26
        propValue    = fread(fid,1,'*double');
    case 32
        stringLength = fread(fid,1,'uint32');
        temp         = fread(fid,stringLength,'*uint8');
        propValue    = native2unicode(temp,UNICODE_FORMAT)';  %#ok<*N2UNI>
        %propValue    = fread(fid,stringLength,'*char')';
    case 33
        propValue = logical(fread(fid,1,'*uint8'));
    case 68
        %Eeek, uint64 really????
        %Time in seconds since 01/01/1904 0 UTC
        %Matlab: days since 01/00/0000 0 i.e. 1 represents 01/01/0000
        firstByte  = fread(fid,1,'uint64');
        secondByte = fread(fid,1,'int64');
        tSeconds = firstByte/(2^64)+secondByte;
        propValue = datestr(tSeconds/SECONDS_IN_DAY + CONV_FACTOR + UTC_DIFF/24,DATE_STR_FORMAT);
    case 524300 %complex single float
        %hex2dec('8000c')
        temp = fread(fid,2,'*single');
        propValue = complex(temp(1),temp(2));
    case 1048589 %complex double float
        %hex2dec('10000d')
        temp = fread(fid,2,'*double');
        propValue = complex(temp(1),temp(2));
    otherwise
        error('Unhandled property type: %s',TDMS_getDataTypeName(propDataType))
end
end

function data_size = TDMS_getDataSize(data_type)
%TDMS_getDataSize  Returns data size in bytes
%
%   This function is used to return the size of raw data for predicting the
%   # of chunks of raw data
%
%   dataSize = TDMS_getDataSize(dataType)
%
%   Inputs
%   ------
%   dataType : Labview dataType
%
%   Outputs
%   -------
%   dataSize : size in bytes
%
%   CALLED BY:
%   - TDMS_preprocessFile
%   - TDMS_handleGetDataOption
%
%   See Also
%   --------
%   TDMS_getPropValue
%   TDMS_getDataTypeName

%https://www.ni.com/en-us/support/documentation/supplemental/07/tdms-file-format-internal-structure.html

%   tdsDataType enum
switch data_type
    case 1 %int8
        data_size = 1;
    case 2 %int16
        data_size = 2;
    case 3 %int32
        data_size = 4;
    case 4 %int64
        data_size = 8;
    case 5 %uint8
        data_size = 1;
    case 6 %uint16
        data_size = 2;
    case 7 %uint32
        data_size = 4;
    case 8 %uint64
        data_size = 8;
    case 9 %Single
        data_size = 4;
    case 10 %Double
        data_size = 8;
    case 25 %Single with unit
        %hex2dec('19')
        data_size = 4;
    case 26 %Double with unit
        data_size = 8;
    case 32
        error('The size of strings is variable, this shouldn''t be called')
    case 33 %logical
        data_size = 1;
    case 68 %timestamp => uint64, int64
        data_size = 16;
    case 524300 %complex single float
        %hex2dec('8000c')
        data_size = 8;
    case 1048589 %complex double float
        %hex2dec('10000d')
        data_size = 16;
        %     case intmax('uint32')
        %         %DAQmx
        %         dataSize = 2; %Will need to be changed
        %         %keyboard
    otherwise
        switch data_type
            case 0
                unhandled_type = 'Void';
            case 11
                unhandled_type = 'Extended float';
                %SIZE: 12 bytes
            case 27
                unhandled_type = 'Extended float with unit';
                %SIZE: 12 bytes
            case 79
                %What's the binary footprint of this?
                unhandled_type = 'Fixed Point';
            case intmax('uint32')
                unhandled_type = 'DAQmx';
                %size?
                %Unfortunately they won't say so I can't just skip it ...
            otherwise
                error('Unrecognized unhandled data type : %d',data_type)
        end
        error('Unhandled property type: %s',unhandled_type)
        %IMPROVEMENT:
        %We could fail silently and document this in the
        %structure (how to read DAQmx (how big to skip?)
end
end

function output = TDMS_initData(dataType,nSamples)
%TDMS_initData  Initializes raw data arrays
%
%   output = TDMS_initData(dataType,nSamples)
%
%   dataType - Labview datatype
%   nSamples - # of samples to initialize to
%
%   See Also: TDMS_getDataTypeName

switch dataType
    case 1
        output   = zeros(1,nSamples,'int8');
    case 2
        output   = zeros(1,nSamples,'int16');
    case 3
        output   = zeros(1,nSamples,'int32');
    case 4
        output   = zeros(1,nSamples,'int64');
    case 5
        output   = zeros(1,nSamples,'uint8');
    case 6
        output   = zeros(1,nSamples,'uint16');
    case 7
        output   = zeros(1,nSamples,'uint32');
    case 8
        output   = zeros(1,nSamples,'uint64');
    case {9 25}
        output   = zeros(1,nSamples,'single');
    case {10 26}
        output   = zeros(1,nSamples,'double');
    case 32
        output   = cell(1,nSamples); %string
    case 33
        output   = false(1,nSamples);
    case 68
        output   = zeros(1,nSamples,'double');
   	case 524300
        output   = zeros(1,nSamples,'like',complex(single(1),single(1)));
  	case 1048589     
        output   = zeros(1,nSamples,'like',complex(1,1));
%     case intmax('uint32')
%         output   = zeros(1,nSamples,'int16');
    otherwise
        error('Unhandled data type for raw data: %s',TDMS_getDataTypeName(dataType))
end
end
