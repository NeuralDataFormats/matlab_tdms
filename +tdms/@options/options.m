classdef options
    %
    %   Class:
    %   tdms.options
    
    
    
    properties (Constant)
        %60s * 60 min * 24 hours
        SECONDS_IN_DAY = 86400;  
        
        %datenum('01-Jan-1904')
        DATE_CONV_FACTOR = 695422; 
        
        STRING_ENCODING = 'UTF-8';
        
        %Eventually we could vary this
        MACHINE_FORMAT  = 'ieee-le';
    end
    
    properties
        utc_diff
        
        verbose
        
        %If true, we look for a matching index file to process
        %the meta data
        use_index = true
        
        %Only read the index. Don't process the file
        index_debug = false
    end
    
    properties
        d2 = '----- Used for one-shot reading ------'
        groups_ignore = -1
        groups_read = -1
        paths_read = -1
        paths_ignore = -1
    end
    
    properties
        d3 = '------ allocation guesses ----'
        n_segs_guess = 25000
        n_segs_increment = 25000
        
        %tdms.meta_chan_info
        n_max_props_guess = 20
        n_objects_guess = 100
    end
    
    properties
        d4 = '------ struct conversion options -----'
        
        replace_str = '_';
        prepend_str = 'v';
        always_prepend = false;

        
        %V4
        s4_replace_str = '_';
        s4_prepend_str = 'p_';
        s4_prepend_group_string = 'g_';
        s4_prepend_chan_string = 'c_';
        s4_always_prepend = false;
        s4_prop_name = 'Props';

        
    end
    
    
    
    methods
        function obj = options()
            %
            %  
            
            %default to local time zone ...
            obj.utc_diff = sl.datetime.getTimeZone();
        end
    end
end

