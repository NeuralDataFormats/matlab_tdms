classdef meta < tdms.sl.obj.handle_light
    %
    %   Class:
    %   tdms.meta
    %
    %   This class can be called directly for testing purposes.
    %
    %   Class Access
    %   ------------
    %   obj = tdms.meta(filepath, *options_in)
    %
    %   Inputs
    %   ------
    %   filepath - Path to tdms file or tdms_index file.
    %   options  - Class: tdms.options
    %
    %   Important Methods:
    %   ------------------
    %   tdms.meta.open_file
    %   tdms.meta.readMeta
    %
    %   See Also
    %   --------
    %   tdms.meta.raw
    
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
        d1 = '-----  File Stuffs  ------'
        fid
        file_open = false
        filepath_input
    end
    
    properties
        d2 = '---- Result Objects -----'
        p_summary    %tdms.meta.processing_summary
        lead_in      %tdms.lead_in
        raw_meta     %tdms.meta.raw
        final_id_info    %tdms.meta.final_id_info
        corrected_seg_info %tdms.meta.corrected_segment_info
        final_segment_info
        
        %fixed_meta   %Class tdms.meta.fixed
        %read_info    %Class tdms.data.read_info
        
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
            
            %TODO: Eventually we might pass in a fid instad of a file_path
            %once we get on to reading the data.
            
            if nargin == 1
                obj.options = tdms.options;
            else
                obj.options = options_in;
            end
            
            obj.p_summary = tdms.meta.processing_summary;
            
            obj.filepath_input = file_path;
            
            %tdms.meta.open_file
            reading_index_file = obj.open_file(file_path);
            
            %Step 1:
            %---------------------------------------------------------------
            %- processing of lead in
            %- extraction of meta data to memory
            obj.lead_in = tdms.lead_in(...
                obj.p_summary,...
                obj.options,...
                obj.fid,...
                reading_index_file);
            
            %tdms.meta.initMetaObject
            obj.initMetaObject();
            
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
        function names_out = fixNames(names_in)
            names_out = cellfun(@h__fixNames,names_in,'un',0);
        end
        function n_bytes_by_type = getNBytesByTypeArray
            %getNBytesByTypeArray
            %
            %   n_bytes_by_type = tdms.meta.getNBytesByTypeArray
            %
            %   Output:
            %   -------
            %   n_bytes_by_type : numeric array, see explanation below
            %
            %Each data type has an integer id associated with it which can range from 1
            %1 - 68, 0 is null and should never come up. I don't explicity test for
            %this as it will throw a warning. Given the integer id, one can index into
            %this array to determine the number of bytes the given type occupies per
            %value.
            
            n_bytes_by_type        = zeros(1,68);
            n_bytes_by_type(1:10)  = [1 2 4 8 1 2 4 8 4 8];
            n_bytes_by_type(25)    = 4;
            n_bytes_by_type(26)    = 8;
            n_bytes_by_type(33)    = 1;
            n_bytes_by_type(68)    = 16;
            
        end
    end
    
end

function name_out = h__fixNames(name_in)
name_out = native2unicode(uint8(name_in),'UTF-8');
end
