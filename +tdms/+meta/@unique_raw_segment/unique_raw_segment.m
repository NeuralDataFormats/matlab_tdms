classdef unique_raw_segment
    %
    %   Class:
    %   tdms.meta.unique_raw_segment
    %
    %   One of these is created for each unique meta data segment.
    %
    %   See Also:
    %   tdms.meta.raw.populateObject
    
    %TODO: We want to hold onto all segments that this applies to.
    
    properties
       first_seg_id
       obj_names    %{1 x n} char
       %These names have not been corrected for UTF-8.
       
       obj_idx_len  %[1 x n] double 
       %Length of the idx data that is valid, 
       %this is either:
       %- 0
       %- 20
       %- 28
       %- intmax('uint32') calculated instead by  2^32 - 1
       obj_idx_data %[6 x n], uint32,
       obj_id       %[1 x n] This is a unique # that is given to 
       %every object. Multiple final objects may have different
       %ids 
    end
    
    methods
        function obj = unique_raw_segment(n)
            if nargin
               obj(n) = tdms.meta.unique_raw_segment;
            end
        end
    end
    
end

