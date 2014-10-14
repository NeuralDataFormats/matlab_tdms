classdef corrected_segment_info
    %
    %   Class:
    %   tdms.meta.corrected_segment_info

    
       %1 - data type
       %2 - # of dimensions of data (only "1" is currently valid)
       %3:4 - # of values, uint64
       %5:6 - # total size in bytes - only for strings
    
    properties
       first_seg_id
       final_obj_ids
       idx_len
       n_bytes_read
       n_values_read
    end
    
    methods
    end
    
end

