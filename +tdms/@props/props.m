classdef props < handle
    %
    
    properties
       names
       values
    end
    
    methods (Static)
       fread_prop_info = get_prop_fread_functions
       fread_prop_info = get_prop_fread_functions2
    end
    
    methods
        function obj = props(prop_names_all,prop_vals_all,prop_chan_ids,nChans)
           %NOTE: might need to do some fixing here
            
            splitPropsByChan(obj,prop_names_all,prop_vals_all,prop_chan_ids,nChans) 
        end
    end
    
end

