classdef fixed < handle
    %
    %   In order to optimize the speed writing the tdms file there are two
    %   optimizations that occur that need to be "corrected" for reading.
    %   
    %   1) During writing, if a property is set for an object, the object
    %   specification can specify that it should use the previous
    %   information given
    %
    %
    %   METHODS
    %   ===================================================================
    %   tdms.meta.fixed.createFinalIDInfo - NOTE: Might move into meta and
    %       pass into this constructor ..., never have as properties
    %   tdms.meta.fixed.fixNInfo          - 
    
    properties (Hidden)
        parent
        raw_meta
    end
    
    properties (Hidden)
        %.createFinalIDInfo
        %------------------------------------------------------------------
        final_obj_id__sorted            %final id sorted, 
        I_sort__raw_to_final            %index of the original value in the sorted data
%         first_instance_of_final_obj     %Not currently used, references the first
%                                         %index in which the final object
%                                         %was referenced, could be used to
%                                         %order objects by write order ...
    end
    
    properties
        %.createFinalIDInfo()
        %------------------------------------------------------------------
        final_obj_id       %(double, row vector, length = raw_meta.n_raw_objs
        %For each raw object id, this gives the final object id
        
        
        %Final properties
        %---------------------------------------------------
        n_unique_objs        %# of unique objects present   
        unique_obj_names     %All unique object names with unicode encoding 
                             %properly handled
        final_obj__data_type %The data type of each final object. There is 
                             %only one value per final id element, i.e.
                             %goes from 1 to n_unique_objs
        
        
        %.fixNInfo()
        n_bytes_per_read__fixed
        n_values_per_read__fixed
        

        %.getDataOrderEachSegment()
        %For raw data only
        seg_id  
        obj_id
    end
    
    methods
        function obj = fixed(meta_obj)
            obj.parent   = meta_obj;
            obj.raw_meta = meta_obj.raw_meta;
            
            %NOTE: Knowing the # of final objects allows us to preallocate
            %data in upcoming function.
            createFinalIDInfo(obj)
            
            
            
            fixNInfo(obj)
            getDataOrderEachSegment(obj)
            
            %NOTE: This maybe should move out of this object ...
            getReadInstructions(obj)
            
        end
      
    end
    
end

