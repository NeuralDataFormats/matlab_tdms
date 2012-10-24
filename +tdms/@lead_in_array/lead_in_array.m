classdef lead_in_array < handle
    %
    %
    %   METHODS
    %   ===============================
    %   tdms.lead_in_array.init_obj
    
    properties (Dependent)
        %FLAGS
        %-----------------
        has_meta_data
        new_obj_list
        has_raw_data
        is_interleaved
        is_big_endian
        has_raw_daqmx
    end
    
    properties
        n_segs
        data_start
        data_length
        meta_start
        toc_mask
    end
    
    properties (Constant)
       LEAD_IN_BYTE_LENGTH = 28; 
    end
    
    methods
        function value = get.has_meta_data(obj)
            value = bitget(obj.toc_mask,2);
        end
        
        function value = get.new_obj_list(obj)
            value = bitget(obj.toc_mask,3);
        end
        
        function value = get.has_raw_data(obj)
            value = bitget(obj.toc_mask,4);
        end
        
        function value = get.is_interleaved(obj)
            value = bitget(obj.toc_mask,6);
        end
        
        function value = get.is_big_endian(obj)
            value = bitget(obj.toc_mask,7);
        end
        
        function value = get.has_raw_daqmx(obj)
            value = bitget(obj.toc_mask,8);
        end
    end
    
    methods
        function obj = lead_in_array(fid,reading_index_file)
            init_obj(obj,fid,reading_index_file)
        end
    end
    
end

