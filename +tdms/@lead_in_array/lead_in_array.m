classdef lead_in_array < handle
    %
    %
    %   METHODS
    %   ===============================
    %   tdms.lead_in_array.init_obj
    %
    %

    
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
        data_starts     %byte index in file where data reading starts
        data_lengths    %byte lengths of all segments
        meta_starts     %byte index in index or data file where meta starts
        meta_data       %cell array of meta data for all segments
    end
    
    properties (Hidden)
        toc_masks       %instructions for each segment
    end
    
    properties (Constant)
       LEAD_IN_BYTE_LENGTH = 28; 
    end
    
    methods
        function value = get.has_meta_data(obj)
            value = bitget(obj.toc_masks,2);
        end
        
        function value = get.new_obj_list(obj)
            value = bitget(obj.toc_masks,3);
        end
        
        function value = get.has_raw_data(obj)
            value = bitget(obj.toc_masks,4);
        end
        
        function value = get.is_interleaved(obj)
            value = bitget(obj.toc_masks,6);
        end
        
        function value = get.is_big_endian(obj)
            value = bitget(obj.toc_masks,7);
        end
        
        function value = get.has_raw_daqmx(obj)
            value = bitget(obj.toc_masks,8);
        end
    end
    
    methods
        function obj = lead_in_array(fid,reading_index_file)
            init_obj(obj,fid,reading_index_file)
        end
    end
    
end

