classdef meta < tdms.sl.obj.handle_light
    %
    %   Class: 
    %   tdms.meta
    %
    %   This class can be called directly for testing purposes.
    %   
    %   Class Access:
    %   -------------
    %   obj = meta(filepath, *options_in)
    %
    %   Inputs:
    %   -------
    %   filepath - Path to tdms file or tdms_index file.
    %   options  - Class: tdms.options
    %
    %   Important Methods:
    %   ------------------
    %   tdms.meta.open_file
    %   tdms.meta.readMeta
    
%==========================================================================
% SECONDS_IN_DAY  = 86400;
% CONV_FACTOR     = 695422; %datenum('01-Jan-1904')
% UTC_DIFF        = -5;
% DATE_STR_FORMAT = 'dd-mmm-yyyy HH:MM:SS:FFF';
    
    
    %OPTIONS  ===================================================
    properties
        options %Class tdms.options
    end
    
    properties
       fid
       file_open = false
       filepath_input
       is_index_only   %Indicates that only an index file was passed in
       %for the file_path.
       reading_index_file %Indicates that we are parsing an index file, 
       %not a data file.
       index_vs_data_reason %Property that briefly describes in text reason
       %for reading meta data from index file or full data file
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
        
    methods (Static)
        function test(file_path,options_in)
           if exist('options_in','var')
               tdms.meta(file_path,options_in);
           else
               tdms.meta(file_path);
           end
        end
    end
    methods
        function obj = meta(file_path,options_in)
           %meta
           %
           %    obj = tdms.meta(file_path,options_in)
           %
           %    Inputs:
           %    -------
           %    file_path : 
           %    options_in : tdms.options

           if nargin == 1
               obj.options = tdms.options;
           else
               obj.options = options_in;
           end
           
           obj.filepath_input = file_path;
           
           %tdms.meta.open_file
           obj.open_file(file_path);
           
           %Step 1:
           %---------------------------------------------------------------
           %- processing of lead in
           %- extraction of meta data to memory
           obj.lead_in = tdms.lead_in(...
               obj.options,...
               obj.fid,...
               obj.reading_index_file);
           
           %tdms.meta.processMeta
           obj.processMeta();
           
           obj.closeFID();
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

