classdef options
    %
    %   Class:
    %   tdms.options
    %
    %   IMPROVEMENTS
    %   ========================================================
    %   1) provide an option for cloning based on previous file for
    %   initialization sizes
    %
    
    %NOTE: I want to put all options in here
    %set the defaults here, let user pass in overriding options
    
    
    %ERROR OPTIONS ========================================================
    properties
       read_file_until_error = false %For Labview this is normally true.
    end
    
    %META OPTIONS =========================================================
    properties
       meta__max_MB_process_data_in_mem = 500;
       meta__data_in_mem_rule = 1
       %0 - never in memory
       %1 - use meta__max_MB_process_data_in_mem
       %2 - always from memory
       
       meta__USE_INDEX      = true       %tdms.meta.open_file
       %By default we will use an index file to parse meta data if it is
       %present in the same directory as the data file. If this is false,
       %then the parser will use the data file to extract meta information
       %if given the data file as an input. If given the index file as an
       %input, this property is ignored and the index is read.
    end
    
    %RAW_OBJ OPTIONS ===========================================
    properties
       raw__INIT_OBJ_SIZE  = 10000 
       raw__INIT_PROP_SIZE = 10000
    end

    %LEAD IN OPTIONS ===========================================
    properties
       lead_in_init_size    = 20000
       lead_in_growth_size  = 20000 
       %TODO: A Doubling might be more useful ...
    end
    
    properties
       UTC_DIFF        = -5;
       USE_INDEX       = true;
       DATE_STR_FORMAT = 'dd-mmm-yyyy HH:MM:SS:FFF';
    end
    
    methods
    end
    
end

