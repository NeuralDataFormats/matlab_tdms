classdef lead_in < handle
    
    properties
        last_letter
        
        %FLAGS
        %-----------------
        has_meta_data
        new_obj_list
        has_raw_data
        is_interleaved
        is_big_endian
        has_raw_daqmx
        
        %INFO
        %-----------------
        ver_number
        seg_length
        meta_length
    end
    
    properties (Constant)
        LEAD_IN_BYTE_LENGTH = 28
    end
    
    %METHODS IN OTHER FILES
    %==============================
    %tdms.lead_in.getProps
    
    methods
        function obj = lead_in(reading_index_file)
            %JAH TODO: Document constructor
            
            if reading_index_file
                obj.last_letter = uint8('h');  %used for .tdms_index files
            else
                obj.last_letter = uint8('m');  %used for .tdms files
            end
        end
    end
    
end