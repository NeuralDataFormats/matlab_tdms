classdef raw_meta
    %A raw object occurs every time that an object is specified in a
    %segment of the meta data. To save time and to actually help
    %processing later on we give each object a unique entry. The
    %alternative is to keep a list of which object is which by comparing
    %the names to each other as we extract the raw data. This leads to a
    %lot of extra comparison that isn't really necessary. Once we have
    %all raw objects we'll pare things down.
    
    properties
        %Length is equal to the # of raw objects      
        %-------------------------------------------------------------------
        raw_obj__names
        raw_obj__seg_id      %assigned segment for each raw object
        raw_obj__idx_len     %row vector????
        %Index length, Importantly:
        %   0       - same as last segment (WITH DATA)
        %   MAX_INT - no data
        
        raw_obj__has_raw_data
        
        %NOTE: These are somewhat incorrect as we haven't taken into
        %account the "same as before" status when obj_len = 0
        %NOTE: n_bytes_per_read is also currently only for strings
        %it will need to be updated later ...
        raw_obj__data_types
        raw_obj__n_values_per_read
        raw_obj__n_bytes_per_read
        
        %Length is by all props across all objects
        %-------------------------------------------------------------------
        prop__names    %names, CHAR, NOT UNICODE
        prop__values   %translated values (i.e.) in type, not uint8
        prop__raw_obj_id %raw object id, note raw objects may be
        %redundant, unique(obj_names) will yield
        %final ids
        prop__types    %a log of property types, this might not be needed ...
    end
    
    methods
    end
    
end

