classdef tdms_object < handle
    %
    %   Class:
    %   tdms.tmds_object
    
    properties
       name
    end
    
    properties (Constant)
       %A path follows the following format:
        %channel objects /'<group>'/'<chan>'
        %groups objects  /'<group>'
        %root            '/' 
       ROOT_PATH = '/'
       OBJECT_NAME_DIVIDER = '''/'''
    end
    
    methods (Static)
        function flag = isRoot(name)
           flag = strcmp(name,tdms_object.ROOT_PATH); 
        end
        
        function flag = isGroup(name)
           %Why might this be wrong ...???
           %See email from that one guy 
           %Seems fine, should look at old code to check
           %length(name) > 1 - hack for root testing
           flag = length(name) > 1 && isempty(strfind(name,'''/'''));
        end
    end
    
end

