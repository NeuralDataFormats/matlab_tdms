classdef lead_in
    %
    %   Class:
    %   tdms.lead_in
    
    properties
        has_meta_data
        kTocNewObjList
        has_raw_data
        is_interleaved
        is_big_endian
        has_raw_daq_mx
        
        ver_number
        segment_length
        meta_length
        
        eof_error
    end
    
    methods
        function obj = lead_in(fid,last_letter)
            
            %1) TDSm - (indicates lead in)
            %-----------------------------
            Ttag = fread(fid,1,'uint8');
            Dtag = fread(fid,1,'uint8');
            Stag = fread(fid,1,'uint8');
            
            %This varies depending on whether we are reading the index
            %file or the main data file
            mtag = fread(fid,1,'uint8');
            
            if ~(Ttag == 84 && Dtag == 68 && Stag == 83 && mtag == last_letter)
                %TODO: show values observed
                error('Unexpected lead in header')
            else
                %2) Kind of Data
                toc_mask = fread(fid,1,'uint32');
                
                obj.has_meta_data = bitget(toc_mask,2);
                obj.kTocNewObjList = bitget(toc_mask,3);
                obj.has_raw_data = bitget(toc_mask,4);
                obj.is_interleaved = bitget(toc_mask,6); %false, contiguous
                obj.is_big_endian = bitget(toc_mask,7); %false, little-endian
                obj.has_raw_daq_mx = bitget(toc_mask,8);
                
                if obj.is_big_endian
                    error('Currently code is unable to handle Big-Endian format')
                end
                
                if obj.has_raw_daq_mx
                    error('Currently code is unable to ignore/handle Raw Daq MX data')
                end
                
                %3) Version Number
                
                obj.ver_number = fread(fid,1,'uint32');
                obj.segment_length = fread(fid,1,'uint64');
                obj.meta_length = fread(fid,1,'uint64');
                
                %NOT THROWING THIS ERROR RIGHT NOW
                %======================================================================
                %This should really quit instead of throwing an error
                obj.eof_error = obj.segment_length == 2^64-1;
                %         if info.segLength == 2^64-1
                %             error('File got corrupted when saving')
                %         end
                
                %This most likely suggests an error in the reading
                if ~obj.eof_error && obj.has_meta_data ~= (obj.meta_length ~= 0)
                    error('Flags suggest presence of meta data but no meta is present according to length value')
                end
                
                
            end
        end
    end
    
end
