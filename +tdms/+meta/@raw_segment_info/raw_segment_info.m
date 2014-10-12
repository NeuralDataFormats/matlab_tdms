classdef raw_segment_info
    %
    %   Class:
    %   tdms.meta.raw_segment_info
    %
    %   One of these is created for each unique meta data segment.
    %
    %   See Also:
    %   tdms.meta.raw.populateObject
    
    properties
       first_seg_id
       
       obj_names    %{1 x n} char
       %These names have not been corrected for UTF-8.
       
       obj_idx_len  %[1 x n] double 
       %Length of the idx data.
       %This is either:
       %- 0  - exactly matches previous specification
       %- 20
       %- 28 - for strings, specifies the total size in bytes
       %- intmax('uint32') calculated instead by  2^32 - 1
       %        - no raw data in this segment
       
       obj_idx_data %[6 x n], uint32,
       %1 - data type
       %2 - # of dimensions of data (only "1" is currently valid)
       %3:4 - # of values, uint64
       %5:6 - # total size in bytes - only for strings
       %
       %
       %    
       
       obj_id       %[1 x n] This is a unique # that is given to 
       %every time any object appears in the meta data.
    end
    
    properties (Dependent)
       data_type
       unprocessed_n_read_values
       unprocessed_n_read_bytes
    end
    
    methods
        function value = get.data_type(obj)
           value = obj.obj_idx_data(1,:); 
        end
        function value = get.unprocessed_n_read_values(obj)
           value = obj.obj_idx_data(3:4,:);
        end
        function value = get.unprocessed_n_read_bytes(obj)
           value = obj.obj_idx_data(5:6,:);
        end
    end
    
    methods
        function obj = unique_raw_segment(n)
            if nargin
               obj(n) = tdms.meta.unique_raw_segment;
            end
        end
    end
    
end

