classdef TDMS_segment_info < handle
    %
    
    properties
       %JAH TODO: Define all of these ...
       %*******
       
       cur_max_length   = 0 
       last_segment_partial = false %The file may not have closed properly, 
       %this is set true when that happens, need to read the last segment carefully ... 
       
       %From the lead_in
       has_meta_data    = []
       has_new_obj_list = []
       haw_raw_data     = []
       is_interleaved   = []
       is_big_endian    = []
       
       
       %populated elsewhere ...
       raw_position   = []
       list_index     = []
       n_raw_objects  = []
       n_samples_read = []
       
       
       n_chunks = []
    end
    
    properties
        GROW_SIZE = 1000;
    end
    
    methods
        function obj = TDMS_segment_info(init_size)
           %JAH TODO: Resize everything ... 
           expand(obj,init_size) 
        end
        
        function expand(obj,n_add)
           %JAH TODO: Implement function 
           %update cur_length
           
           
           obj.is_interleaved = [obj.is_interleaved   false(1,n_add)];
           obj.is_big_endian  = [obj.is_big_endian   false(1,n_add)];
           obj.has_meta_data  = [obj.has_meta_data   false(1,n_add)];
           obj.has_new_obj_list = [obj.has_new_obj_list false(1,n_add)];
           obj.haw_raw_data   = [obj.haw_raw_data false(1,n_add)];
           
           obj.raw_position   = [obj.raw_position zeros(1,n_add)];
           obj.list_index     = [obj.list_index   zeros(1,n_add)];
           obj.n_raw_objects  = [obj.n_raw_objects   zeros(1,n_add)];
           obj.n_samples_read = [obj.n_raw_objects   zeros(1,n_add)];
           obj.n_chunks       = [obj.n_chunks   zeros(1,n_add)];
           
           obj.cur_max_length = length(obj.n_chunks);
           
        end
    end

    
end

