classdef lead_in
    %
    
    properties
        hasMetaData
        kTocNewObjList
        hasRawData
        isInterleaved
        isBigEndian
        hasRawDaqMX
    end
    
    methods
        function obj = lead_in(fid,lastLetter)
            
            %1) TDSm - (indicates lead in)
            %-----------------------------
            Ttag = fread(fid,1,'uint8');
            Dtag = fread(fid,1,'uint8');
            Stag = fread(fid,1,'uint8');
            
            %This varies depending on whether we are reading the index
            %file or the main data file
            mtag = fread(fid,1,'uint8');
            
            if ~(Ttag == 84 && Dtag == 68 && Stag == 83 && mtag == lastLetter)
                %TODO: show values observed
                error('Unexpected lead in header')
            else
                %2) Kind of Data
                tocMask = fread(fid,1,'uint32');
                
                    obj.hasMetaData = bitget(tocMask,2);
                    obj.kTocNewObjList = bitget(tocMask,3);
                    obj.hasRawData = bitget(tocMask,4);
                    obj.isInterleaved = bitget(tocMask,6); %false, contiguous
                    obj.isBigEndian = bitget(tocMask,7); %false, little-endian
                    obj.hasRawDaqMX = bitget(tocMask,8));
                
                if flags.isBigEndian
                    error('Currently code is unable to handle Big-Endian format')
                end
                
                if flags.hasRawDaqMX
                    error('Currently code is unable to ignore/handle Raw Daq MX data')
                end
                
                %3) Version Number
                info = struct(...
                    'verNumber',  fread(fid,1,'uint32'),...  %This is not very well defined
                    'segLength',  fread(fid,1,'uint64'),...
                    'metaLength', fread(fid,1,'uint64'));
                
                %NOT THROWING THIS ERROR RIGHT NOW
                %======================================================================
                %This should really quit instead of throwing an error
                eof_error = info.segLength == 2^64-1;
                %         if info.segLength == 2^64-1
                %             error('File got corrupted when saving')
                %         end
                
                %This most likely suggests an error in the reading
                if ~eof_error && flags.hasMetaData ~= (info.metaLength ~= 0)
                    error('Flags suggest presence of meta data but no meta is present according to length value')
                end
                
                
            end
        end
    end
    
