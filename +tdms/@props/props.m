classdef props < handle
    %
    %   Class:
    %   tdms.props
    
    properties
       parent
    end
   
    %NOTE: I can do a bit with dependent variables
    %here to make this easier to look at
    %But goal will be to match previous format
    %so this is temporary  ...
    
    properties
       names_value_struct_array
       %.names - cellstr
       %.values - cell array
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
           organizeProps(obj);
        end
        
%         function obj = props(prop_names_all,prop_vals_all,prop_chan_ids,nChans)
%            %NOTE: might need to do some fixing here
%             
%             splitPropsByChan(obj,prop_names_all,prop_vals_all,prop_chan_ids,nChans) 
%         end
    end
    
end

