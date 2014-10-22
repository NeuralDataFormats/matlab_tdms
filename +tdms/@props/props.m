classdef props < handle
    %
    %   Class:
    %   tdms.props
    %
    %   Improvements:
    %   -------------
    %   1) At some point I wanted to provide the option as to how the
    %   properties were converted, primarily in allowing numerical values
    %   to all be converted to doubles (or not), and date/time handling
    
    %TODO: Validate that values are of proper type
    
    properties
        parent %tdms.meta
    end
    
    %NOTE: I can do a bit with dependent variables
    %here to make this easier to look at
    %But goal will be to match previous format
    %so this is temporary  ...
    
    properties
        n_objs_with_properties
        final_obj_ids %{1 x n_objs_with_properties}
        %   Each object that
        prop_names  %{1 x n_objs_with_properties}
        prop_values %{1 x n_objs_with_properties}
        
        
        %TODO: Could do a final object to final object with properties map
        %indices - 1:n_final_objects
        %values  - indice in final_obj_ids above
        
        
    end
    
    methods (Static)
        %tdms.props.get_prop_fread_functions
        fread_prop_info = get_prop_fread_functions()
        
        %This isn't being used. I'm not sure why I had this ..
        %Perhaps I wanted to allow passing in non-string values ...
        fread_prop_info = get_prop_fread_functions2()
    end
    
    methods
        
        function obj = props(meta_obj)
            obj.parent = meta_obj;
            obj.organizeProps();
        end
    end
    
end

