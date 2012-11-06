classdef final_id < handle
    %
    
    properties
        parent
    end
    
    properties
        final_obj_id__sorted            %final id sorted,
        I_sort__raw_to_final            %index of the original value in the sorted data
        %         first_instance_of_final_obj     %Not currently used, references the first
        %                                         %index in which the final object
        %                                         %was referenced, could be used to
        %                                         %order objects by write order ...
        
        %.createFinalIDInfo()
        %------------------------------------------------------------------
        %length = raw_meta.n_raw_objs
        final_obj_id       %(double, row vector, length = raw_meta.n_raw_objs
        %For each raw object id, this gives the final object id
        
        %Final properties
        %---------------------------------------------------
        %.createFinalIDInfo()
        %-----------------------
        n_unique_objs        %# of unique objects present
        unique_obj_names     %(length = n_unique_objs) All unique object
        %names with unicode encoding properly handled
        
    end
    
    methods
        function obj = final_id(meta_obj)
            obj.parent = meta_obj;
            createFinalIDInfo(obj)
        end
    end
    
end

