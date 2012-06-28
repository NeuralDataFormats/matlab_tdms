classdef TDMS_meta_options < handle
    %
    
    properties
       UTC_DIFF  = -5 %This will report times in Eastern Standard Time
       USE_INDEX = true    %Parse meta data from index if present
       MAX_NUM_OBJECTS 
       MAX_NUM_PROPS  
        N_SEGS_GUESS   
        N_SEGS_INC   
        DEBUG          
        DATE_STR_FORMAT 
        UNICODE_FORMAT   
        INIT_CHUNK_SIZE
        TDMS_INDEX_EXT 
        MACHINE_FORMAT 
        STRING_ENCODING
        CURRENT_VERSION
        INDEX_DEBUG    
       
    end
    
    methods
    end
    
end

