classdef meta < handle
    %
    
%==========================================================================
% SECONDS_IN_DAY  = 86400;
% CONV_FACTOR     = 695422; %datenum('01-Jan-1904')
% UTC_DIFF        = -5;
% DATE_STR_FORMAT = 'dd-mmm-yyyy HH:MM:SS:FFF';
    
    
    %OPTIONS  ===================================================
    properties
        options_obj  %Class tdms.options
    end
    
    properties        
        lead_in %(class tdms.lead_in)
        raw_meta     %Class tdms.meta.raw
        final_ids    %Class tdms.meta.final_id
        fixed_meta   %Class tdms.meta.fixed
        read_info    %Class tdms.data.read_info
        
        props        %Class tdms.props
        
        fid
        is_index_only %indicates that the filename passed in was the index file
        reading_index_file
        
        
    end
    
    properties (Constant,Hidden)
       TDMS_INDEX_FILE_EXTENSION = '.tdms_index';
       TDMS_FILE_EXTENSION       = '.tdms';
       STRING_ENCODING           = 'UTF-8';
       
       %NOTE: This could eventually vary ...
       MACHINE_FORMAT            = 'ieee-le'
    end
        
    methods
        function obj = meta(filepath,options_in)
           %
           %
           %

           if nargin == 1
               obj.options_obj = tdms.options;
           else
               obj.options_obj = options_in;
           end
              
           %tmds.meta.open_file
           open_file(obj,filepath);
           
           %tdms.meta.readMeta
           readMeta(obj)
        end
    end
    
    methods (Static)
       names_out = fixNames(names_in) 
       n_bytes_by_type = getNBytesByTypeArray
    end
    
end

