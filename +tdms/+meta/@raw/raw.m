classdef raw < handle
    %
    %A raw object occurs every time that an object is specified in a
    %segment of the meta data. To save time and to actually help
    %processing later on we give each object a unique entry. The
    %alternative is to keep a list of which object is which by comparing
    %the names to each other as we extract the raw data. This leads to a
    %lot of extra comparison that isn't really necessary. Once we have
    %all raw objects we'll pare things down.
    %
    %   METHODS
    %   ===========================================
    %   tdms.meta.raw.populateObject
    
    properties
       parent
       options_obj
       lead_in
    end
    
    properties
        %Length is equal to the # of raw objects      
        %-------------------------------------------------------------------
        n_raw_objs           %Length of all raw_obj properties below 
        
        raw_obj__names
        raw_obj__seg_id      %assigned segment for each raw object
        raw_obj__idx_len     %(double, row vector), Index Length
        %Importantly:
        %   0       - same as last segment (that had data)
        %   MAX_INT - intmax('int32') - no data
        
        %Dependent variables (not made dependent)
        raw_obj__has_raw_data %Whether or not idx_len = MAX_INT
        %IMPORTANTLY: This doesn't guarantee that the object actually has
        %data. Some writers may specify an 
        
        %NOTE: These are somewhat incorrect as we haven't taken into
        %account the "same as before" status when obj_len = 0
        %NOTE: n_bytes_per_read is also currently only for strings
        %it will need to be updated later ...
        raw_obj__data_types        %
        raw_obj__n_values_per_read %(double, row vector)
        raw_obj__n_bytes_per_read  %(double, row vector)
        
        %Length is by all props across all objects
        %-------------------------------------------------------------------
        n_props         
        prop__names      %names, CHAR, NOT UNICODE
        prop__values     %translated values (i.e.) in type, not uint8
        prop__raw_obj_id %raw object id, note raw objects may be
        %redundant, unique(obj_names) will yield
        %final ids
        prop__types    %a log of property types, this might not be needed ...
    end
    
    methods
        function obj = raw(meta_obj)
           obj.parent      = meta_obj;
           obj.options_obj = meta_obj.options_obj;
           obj.lead_in     = meta_obj.lead_in;
           
           populateObject(obj) 
        end
    end
    
end

