classdef group
    %
    %   Class:
    %   tdms.group
    %
    %   See Also
    %   --------
    %   tdms.channel
    
    properties
        parent
        group_name
    end
    
    methods
        function obj = group(parent,group_name)
            obj.parent = parent;
            obj.group_name = group_name;
        end
        function getChannel(obj,chan_name)
            
        end
        function getChannels(obj,chan_names)
            
        end
    end
end

