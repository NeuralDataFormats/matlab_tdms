classdef meta < handle_light
    %
    %   Class: tdms.meta
    %
    %   This class can be called directly for testing purposes.
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
       filepath_input
       is_index_only   %Indicates that only an index file was passed in
       %for the file_path.
       reading_index_file %Indicates that we are parsing an index file, 
       %not a data file.
    end
    
    properties        
        lead_in      %Class tdms.lead_in
        raw_meta     %Class tdms.meta.raw
        final_ids    %Class tdms.meta.final_id
        fixed_meta   %Class tdms.meta.fixed
        read_info    %Class tdms.data.read_info
        
        props        %Class tdms.props
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
              
           
           obj.filepath_input = filepath;
           
           %tmds.meta.open_file
           open_file(obj,filepath);
           
           %Step 1: Processing of the lead ins and extraction of meta data to memory
           %--------------------------------------------------------------------------
           obj.lead_in = tdms.lead_in(filepath,obj.options_obj);

           %tdms.meta.readMeta
           processMeta(obj)
           
           closeFID(obj)
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
           %    See Also:
           %        tdms.meta.open_file
           
           fclose(obj.fid);
           obj.fid = -1;
           obj.file_open = false;
        end
    end
    
    methods (Static,Hidden)
       
       names_out = fixNames(names_in) 
       
       n_bytes_by_type = getNBytesByTypeArray
    end
    
end

