classdef final_id < handle
    %
    %   Class: tdms.meta.final_id
    %
    %   Created by:
    %       tdms.meta.readMeta
    
    properties
        parent %Class: tdms.meta
    end
    
    
    properties
        %I think these are temporary variables and should be removed
        
        %? What is the purpose of this variable?
        final_obj_id__sorted            %final id sorted
        
        I_sort__raw_to_final            %index of the original value in the sorted data
        %         first_instance_of_final_obj     %Not currently used, references the first
        %                                         %index in which the final object
        %                                         %was referenced, could be used to
        %                                         %order objects by write order ...
    end
    
    properties
        %.createFinalIDInfo()
        %------------------------------------------------------------------
        %length = raw_meta.n_raw_objs
        final_obj_id       %(double, row vector, length = raw_meta.n_raw_objs
        %For each raw object id, this gives the final object id
        %This is in read order, i.e. the value at index 1 is the first
        %object mentioned in the file, the second index is the second
        %mentioned object in the file.
        
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

