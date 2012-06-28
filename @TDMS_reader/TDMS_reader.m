classdef TDMS_reader < handle
    %
    
    properties
        meta
    end
    
    methods
        function obj = TDMS_reader(filePath,meta_options)
           
           if ~exist('meta_options','var')
               meta_options = [];
           end
            
           obj.meta = TDMS_meta(filePath,meta_options); 
        end
    end
    
end

