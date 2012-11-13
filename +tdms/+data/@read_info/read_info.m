classdef read_info < handle
    %
    
    properties
       parent
    end
    
    methods
        function obj = read_info(meta_obj)
           obj.parent = meta_obj;
           getReadInstructions(obj)
        end
    end
    
end

