classdef meta < handle_light
    %
    %   Class Access:
    %   -------------------------------------------------
    %   obj = meta(filepath, *options_in)
    %
    %   INPUTS:
    %       filepath - Path to tdms file or tdms_index file.
    %       options  - Class: tdms.options
    %
    %   IMPORTANT METHODS
    %   -------------------------------------------------
    %   tdms.meta.open_file
    %   tdms.meta.readMeta
    
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
        lead_in      %Class tdms.lead_in
        raw_meta     %Class tdms.meta.raw
        final_ids    %Class tdms.meta.final_id
        fixed_meta   %Class tdms.meta.fixed
        read_info    %Class tdms.data.read_info
        
        props        %Class tdms.props
    end
    
    properties
        fid                 %Matlab file id reference to open file
        file_open  = false  %Boolean to know if file is still open
                            %Could check "fid" but this might not belong to
                            %the class anymore
        is_index_only       %indicates that the filename passed in was the index file
        reading_index_file  %property that indicates if fid represents index file or data file
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
           %meta
           %
           %    obj = meta(filepath,options_in)
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
    
    methods (Hidden)
        function delete(obj)
           if obj.file_open
              fclose(obj.fid); 
           end
        end
        function closeFID(obj)
           %closeFID 
           %
           %    This method helps us know if 
           %
           %    See Also:
           %        tdms.meta.open_file
           
           fclose(obj.fid);
           obj.file_open = false;
        end
    end
    
    methods (Static,Hidden)
       
       names_out = fixNames(names_in) 
       
       n_bytes_by_type = getNBytesByTypeArray
    end
    
end

