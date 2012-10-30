classdef meta < handle
    %
    
%==========================================================================
% SECONDS_IN_DAY  = 86400;
% CONV_FACTOR     = 695422; %datenum('01-Jan-1904')
% UTC_DIFF        = -5;
% DATE_STR_FORMAT = 'dd-mmm-yyyy HH:MM:SS:FFF';
    
    
    %OPTIONS  ===================================================
    properties
        opt_USE_INDEX       = true
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
        
        n_objs    = 0
        obj_names = {}
        n_objs_allocated = 0
        
        props
            %.names
            %.values
        
        
        raw_meta %Class tdms.raw_meta
        
        n_bytes_per_read
        n_values_per_read
        
        %-----------------------------------------------
        raw_n_bytes_read
        raw_n_values_read
        raw_index_start
        raw_data_type
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
           %
           %
           %
           

           
           %tmds.meta.open_file
           open_file(obj,filepath);
           
           %tdms.meta.readMeta
           readMeta(obj)
           
           %NOTE: It would be nice to hide this from the programmer
           %obj.lead_in = tdms.lead_in(obj.reading_index_file); 
        end
    end
    methods (Static)
       %obj_props = getObjProps(orig_obj_final_id,prop_chan_ids,prop_names,prop_values,n_unique_objs) 
    end
    
end

