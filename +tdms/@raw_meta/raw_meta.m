classdef raw_meta
    %
    
    properties
       %Length is by all object instances
       %NOT unique objects
       %-------------------------------------------------------------------
       obj_names
       obj_seg      %assigned segment for each raw object
       obj_len      %row vector????
                    %Index length
                    %Importantly:
                    %0       - same as last segment (WITH DATA)
                    %MAX_INT - no data            
       obj_has_raw_data 
       
       %NOTE: These are somewhat incorrect
       %as we haven't taken into account the "same as before" status
       %when obj_len = 0 
       %NOTE: n_bytes_per_read is also currently only for strings
       %it will need to be updated later ...
       obj_data_types
       obj_n_values_per_read
       obj_n_bytes_per_read
       
       %Length is by all props across all objects
       %-------------------------------------------------------------------
       prop_names    %names, CHAR, NOT UNICODE
       prop_values   %translated values (i.e.) in type, not uint8
       prop__raw_obj_id %raw object id, note raw objects may be 
                        %redundant, unique(obj_names) will yield
                        %final ids
       prop_types    %a log of property types, this might not be needed ...
    end
    
    methods
    end
    
end

