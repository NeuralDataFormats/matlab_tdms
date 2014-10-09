classdef final_id < handle
    %
    %   Class: tdms.meta.final_id
    %
    %   Created by:
    %       tdms.meta.readMeta
    %
    %
    %   This class is currently being rewritten.
    %
    %
    %   
    
    
    properties
        parent %Class: tdms.meta
    end
    
    properties
        n_unique_objs
        unique_obj_names %All unique object names with unicode 
        %encoding properly handled
        
        %I think we are probably going to need:
        %
        %- for each final object (DELAYING FOR NOW)
        %   - pointer to the unique segment info
        %   - pointer to index in the unique segment info
        %
        %- for each raw id
        %   - pointer to final id
        
        raw_id_to_final_id_map
        %give a raw id (as index)
        %get a final id (as value)
        
        
    end
    
    methods
        function obj = final_id(meta_obj)
            %
            %   obj = final_id(meta_obj)
            %
            %   tdms.meta.final_id 
            obj.parent = meta_obj;
            
            %tdms.meta.final_id.createFinalIDInfo
            obj.createFinalIDInfo();
        end
    end
    
end

