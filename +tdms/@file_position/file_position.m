classdef file_position < handle
    %
    %   Class:
    %   tdms.file_position
    
    properties
        meta_fid
        meta_eof_position
    end
    
    methods
        function obj = file_position(meta_fid)
            %
            %   file_position = tdms.file_position(meta_fid)
            
            obj.meta_fid = meta_fid;
            
            fseek(meta_fid,0,1);
            obj.meta_eof_position = ftell(meta_fid);
            fseek(meta_fid,0,-1);
        end
        function flag = atMetaEnd(obj)
            flag = ftell(obj.meta_fid) == obj.meta_eof_position;
        end
    end
end

