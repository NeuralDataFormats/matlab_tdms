classdef fixed < handle
    %
    
    properties (Hidden)
        parent
        raw_meta
    end
    
    properties (Hidden)
        %Part 1 - final ids .createFinalIDInfo
        %---------------------------------------------
        final_obj_id__sorted  %final id sorted, 
        I_sort__raw_to_final  %index of the original value
        first_instance_of_final_obj
    end
    
    properties
        %Part 1 - final ids .createFinalIDInfo
        %---------------------------------------------
        final_obj_id       %For each raw object id, this gives the final object id
        n_unique_objs      %# of unique objects present   
        unique_obj_names   %
        
        final_obj__data_type %TODO: Document
    end
    
    methods
        function obj = fixed(meta_obj)
            obj.parent   = meta_obj;
            obj.raw_meta = meta_obj.raw_meta;
            
            createFinalIDInfo(obj)
            fixNInfo(obj)
            
        end
        function createFinalIDInfo(obj)
            
            %MLINT
            %=====================
            %#ok<*PROP>  %property reference as variable
            [sorted_names,I_sort__raw_to_final] = sort(obj.raw_meta.raw_obj__names);
            I_diff  = find(~strcmp(sorted_names(1:end-1),sorted_names(2:end)));
            I_start = [1 I_diff + 1];
            
            %NOTE: We may eventually want this information ...
            %obj.first_instance_of_final_obj = I_sort__raw_to_final(I_start);
            
            final_obj_id__sorted = zeros(1,raw_meta_obj.n_raw_objs); 
            final_obj_id__sorted(I_start) = 1;
            final_obj_id__sorted = cumsum(final_obj_id__sorted);
            final_obj_id(I_sort__raw_to_final) = final_obj_id__sorted;
            n_unique_objs = length(sorted_names);
            
            obj.final_obj_id__sorted = final_obj_id__sorted;
            obj.final_obj_id         = final_obj_id;
            obj.n_unique_objs        = n_unique_objs;
            obj.I_sort__raw_to_final = I_sort__raw_to_final;
            
            %Fix the object names
            obj.unique_obj_names = tdms.meta.fixNames(sorted_names(I_start));
        end
    end
    
end

