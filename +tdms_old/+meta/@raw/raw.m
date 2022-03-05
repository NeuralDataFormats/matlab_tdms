classdef raw < tdms.sl.obj.handle_light
    %
    %   Class: 
    %   tdms.meta.raw
    %
    %     A raw object occurs every time that an object is specified in a
    %     segment of the meta data. To save time and to actually help
    %     processing later on, we give each object a unique entry. The
    %     alternative is to keep a list of which object is which by
    %     comparing the names to each other as we extract the raw data.
    %     This leads to a lot of extra comparison that isn't really
    %     necessary. Once we have all raw objects we'll pare things down.
    %
    %   METHODS
    %   ===========================================
    %   tdms.meta.raw.populateObject
    
    properties
        parent      %Class: tdms.meta
        options     %Class: tdms.options
        lead_in     %Class: tdms.lead_in
    end
    
    properties
        d1 = '-----  segment data info -----'
        n_unique_meta_segments
        n_segments
        unique_segment_info %tdms.meta.raw_segment_info
        %Ordered by their first occurence
        ordered_segment_info    %[1 x n_segments], %tdms.meta.raw_segment_info
        %Same as unique_segment_info but there is one per segment. Objects
        %are ordered by segment.
        
        n_raw_objs  %# of times something was specified about an object
        %in the headers. Things such as:
        %- adding to the read list again
        %- initialization of an object
        %- adding a property to an object
    end
    
    properties
       full_to_unique_map %Basically the IC output from unique
       %specifying how to go from the unique_segment_info to the 
       %ordered_segment_info
       %
       %ordered_segment_info = unique_segment_info(full_to_unique_map)
       %
       %- give the original segment (as index)
       %- get the unique info for that segment (as value)
    end
    
    %{
    
    properties
        %Length is equal to the # of raw objects
        %-------------------------------------------------------------------
        
        
        raw_obj__names       %Name of each object, without being 
        %corrected for Unicode.
        
        raw_obj__seg_id      %Assigned segment for each raw object. 
        %Each lead_in starts a new segment. Multiple objects can be
        %specifieid in each segment. %TODO: Clarify this, I don't
        %understand what this means ...
        
        raw_obj__idx_len     %(double, row vector), Index Length
        %Index length specifies how many bytes are available to describe 
        %the data. Index length is the name given in the file format 
        %specification, not mine ...
        %In some cases a different interpretation is needed:
        %   0       - same as last segment (that had data)
        %   MAX_INT - intmax('int32') - no data
        
        %Dependent variables (not made dependent)
        %i.e. the following few raw_obj variables are computed
        %based on the above properties
        raw_obj__has_raw_data %obj.raw_obj__idx_len ~= MAX_INT
        %IMPORTANTLY: This being true doesn't guarantee that the object
        %actually has data. Some writers may specify that raw data is present
        %but that the # of values present in the segment for that object is 0
    end
    
    properties
        %NOTE: These are somewhat incorrect as we haven't taken into
        %account the "same as before" status when obj_len = 0
        %NOTE: n_bytes_per_read is also currently only for strings
        %it will need to be updated later ...
        raw_obj__data_types        %
        raw_obj__n_values_per_read %(double, row vector)
        raw_obj__n_bytes_per_read  %(double, row vector)
    end
    %}
    
    properties
        d2 = '------  Raw Property Info ------'
        %Length is by all props across all objects
        %In other words, we have not paired the information down to being
        %on a per object basis. ??? Have we filtered properties?
        %-------------------------------------------------------------------
        n_props
        prop__names      %names, CHAR, NOT UNICODE
        prop__values     %translated values (i.e.) in type, not uint8
        prop__raw_obj_id %raw object id.
        prop__types    %a log of property types, this might not be needed ...
    end
    
    methods
        function obj = raw(meta_obj)
            %
            %   obj = tdms.meta.raw(meta_obj)
            %
            %   Inputs:
            %   -------
            %   meta_obj : tdms.meta
            %
            obj.parent  = meta_obj;
            obj.options = meta_obj.options;
            obj.lead_in = meta_obj.lead_in;
            
            %tdms.meta.raw.populateObject
            obj.initMetaRawObject();
        end
    end
    
end

