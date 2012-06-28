classdef TDMS_meta < handle
    %
    
    properties
       OPTIONS
       file_path
       file_name
       fid
       cur_seg_index
       seg_info
       
       %Indexing props
       meta_only
       meta_from_index
    end
    
    methods
        function obj = TDMS_meta(filePath,meta_options)
           
           if ~exist('meta_options','var') || isempty(meta_options)
              obj.OPTIONS = TDMS_meta_options;
           else
              obj.OPTIONS = meta_options;
           end
            
           
           [file_root,file_name,file_ext] = fileparts(filePath);
           
           obj.file_path = filePath;
           
           
           
           %NOTE: Need to handle fid
           init_meta_obj_index_ver(obj)
           
        end
    end
    
end

