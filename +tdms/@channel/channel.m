classdef channel < handle
    %
    %   Class:
    %   tdms.channel
    %
    %   See Also
    %   --------
    %   tdms.group
    
    properties
        group_name
        channel_name
        data
        prop_names
        prop_values
        props
    end
    
    methods
        function obj = channel(name,prop_names,prop_values)
            %
            %   chan = tdms.channel(name,prop_names,prop_values)
            
            obj.name = name;
            obj.prop_names = prop_names;
            obj.prop_values = prop_values;
            %TODO: obj.props
        end
    end
end

