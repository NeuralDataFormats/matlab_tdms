classdef final_id_info < handle
    %
    %   Class: 
    %   tdms.meta.final_id_info
    %
    %   Created by:
    %       tdms.meta.readMeta
    
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
        function obj = final_id_info(meta_obj)
            %
            %   obj = tdms.meta.final_id_info(meta_obj)
            %
            
            obj.parent = meta_obj;
            
            %tdms.meta.final_id_info.initFinalIDInfo
            obj.initFinalIDInfo();
        end
    end
    
end

