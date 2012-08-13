classdef meta < handle
    %
    
    %NM, do decision here 
    
    

%==========================================================================
% SECONDS_IN_DAY  = 86400;
% CONV_FACTOR     = 695422; %datenum('01-Jan-1904')
% UTC_DIFF        = -5;
% DATE_STR_FORMAT = 'dd-mmm-yyyy HH:MM:SS:FFF';
    
    
    properties
        opt_USE_INDEX = true
        opt_OBJ_GROWTH_RATE = 20; 
    end
    
    properties
        
        %TODO
        %======================
        %Include data ...
        
        lead_in %(class tdms.lead_in)
        
        fid
        is_index_only %previously INDEX_DEBUG
        %indicates that the filename passed in was the index file
        reading_index_file = true
        
        n_objs = 0
        obj_names = {}
        n_objs_allocated = 0
        
        %Data to hold onto for each object ...
        %---------------------------------------------------
        
        n_props_total
        prop_names
        prop_vals
        prop_chan_ids 
        
        %-----------------------------------------------
        raw_n_bytes_read
        raw_n_values_read
        raw_index_start
        raw_chan_id
        n_seg_reads
        
    end
    
    properties (Constant)
       TDMS_INDEX_FILE_EXTENSION = '.tdms_index';
       TDMS_FILE_EXTENSION       = '.tdms';
       STRING_ENCODING           = 'UTF-8';
       MACHINE_FORMAT            = 'ieee-le'
    end
    
    
    
    methods
        function obj = meta(filepath)
           %Potential usage options
           %1) - no arguments, just get object for setting options
           
           %I think at this point I do the file reading 
           
           %tmds.meta.open_file
           open_file(obj,filepath);
           
           %tdms.meta.readMeta
           readMeta(obj)
           
           %NOTE: It would be nice to hide this from the programmer
           %obj.lead_in = tdms.lead_in(obj.reading_index_file); 
        end
        
      
    end
    
end

