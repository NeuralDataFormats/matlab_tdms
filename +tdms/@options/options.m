classdef options
    %
    %   IMPROVEMENTS
    %   ========================================================
    %   1) provide an option for cloning based on previous file for
    %   initialization sizes
    %
    
    %NOTE: I want to put all options in here
    %set the defaults here, let user pass in overriding options
    
    %META OPTIONS ==============================================
    properties
       meta_USE_INDEX
       meta_OBJ_GROWTH_RATE
    end
    
    %RAW_OBJ OPTIONS ===========================================
    properties
       raw__INIT_OBJ_SIZE  = 10000 
       raw__INIT_PROP_SIZE = 10000
    end
    
    
    %LEAD IN OPTIONS ===========================================
    properties
       lead_in_INIT_SIZE    = 20000
       lead_in_GROWTH_SIZE  = 20000
    end
    
    properties
       UTC_DIFF        = -5;
       USE_INDEX       = true;
       DATE_STR_FORMAT = 'dd-mmm-yyyy HH:MM:SS:FFF';
    end
    
    methods
    end
    
end

