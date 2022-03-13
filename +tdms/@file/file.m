classdef file
    %
    %   tdms.file
    
    %{
        file_path = '/Users/jim/Library/CloudStorage/Box-Box/__non_shared/HOME/files_for_code_problems/matlab_tdms/2022_03_01__AdamDempsey/2022-02-08_MEEN6995_Rail_P_sweep_Run006_raw_processed.tdms';
        
        profile on
        tic
        n = 1;
        for i = 1:n
            wtf = tdms.file(file_path);
            wtf.readAllData();
        end
        toc/n
        profile off
        profile viewer
    
        tic
        n = 1;
        for i = 1:n
            wtf = TDMS_getStruct(file_path);
        end
        toc/n
        
        
    
    %}
    
    properties
        meta tdms.meta
        options tdms.options
        file_fid
    end
    
    methods
        function obj = file(file_path)
            
            obj.options = tdms.options();
            
            %NOTE: Eventually this could be 
            %passed into fread for support of different endianess
            
            if ~obj.options.index_debug
                obj.file_fid = fopen(file_path,'r',...
                    obj.options.MACHINE_FORMAT,...
                    obj.options.STRING_ENCODING);
            else
                obj.file_fid = []; %Don't open the .tdms file, .tdms_index only
            end
            
            obj.meta = tdms.meta(obj.file_fid,file_path,obj.options);
            
        end
        function delete(obj)
            fclose(obj.file_fid);
        end
        function output = getStruct(obj,struct_version)
            switch struct_version
                case 1
                    output = TDMS_dataToGroupChanStruct_v1(obj);
                case 2
                case 3
                case 4
                    output = TDMS_dataToGroupChanStruct_v4(obj);
                otherwise
                    error('Unrecognized struct version option: %d',struct_version);
            end
        end
    end
end



function output = TDMS_dataToGroupChanStruct_v1(obj)
%TDMS_dataToGroupChanStruct_v1  
%
%   output = TDMS_dataToGroupChanStruct_v1(inputStruct)
%
%   See Also: TDMS_genvarname2

options = obj.options;

propNames    = inputStruct.propNames;
propValues   = inputStruct.propValues;
groupIndices = inputStruct.groupIndices;
groupNames   = inputStruct.groupNames;
chanIndices  = inputStruct.chanIndices;
chanNames    = inputStruct.chanNames;
rootIndex    = inputStruct.rootIndex;
data         = inputStruct.data;

output = struct('props',...
    struct('name',{propNames{rootIndex}},...
        'value',{propValues{rootIndex}})); %#ok<*CCAT1>

fh = @(x)TDMS_genvarname2(x,...
            options.s1_replace_str,...
            options.s1_prepend_str,...
            options.s1_always_prepend);    
    
for iGroup = 1:length(groupIndices)
    curGroupIndex = groupIndices(iGroup);
    curChanIndices = chanIndices{iGroup};
    curChanNames   = chanNames{iGroup};
    groupStruct = struct('name',groupNames(iGroup),'props',...
        struct('name',{propNames{curGroupIndex}},...
        'value',{propValues{curGroupIndex}}));
    for iChan = 1:length(curChanIndices)
        curChanIndex = curChanIndices(iChan);
        chanStruct =  struct('name',curChanNames{iChan},'props',...
            struct('name',{propNames{curChanIndex}},...
            'value',{propValues{curChanIndex}}),...
            'data',[]);
        chanStruct.data = data{curChanIndex};
        %NOTE: I had a case statement in case the data type was a string,
        %which would change the interpretation of the struct input
        groupStruct.(fh(chanStruct.name)) = chanStruct;
    end
    output.(fh(groupStruct.name)) = groupStruct;
end
end

function output = TDMS_dataToGroupChanStruct_v4(obj)
%TDMS_dataToGroupChanStruct_v4  
%
%   NOTE: This reproduces the data structure for the old lab functionality 
%   of the function getStructTDM
%   
%   See Also: TDMS_genvarname2, TDMS_readTDMSFile

options = obj.options;

rpa = {options.s4_replace_str,options.s4_prepend_str,options.s4_always_prepend};

fh = @(x)TDMS_genvarname2(x,rpa{:});  

propNames    = inputStruct.propNames;
propValues   = inputStruct.propValues;
groupIndices = inputStruct.groupIndices;
groupNames   = inputStruct.groupNames;
chanIndices  = inputStruct.chanIndices;
chanNames    = inputStruct.chanNames;
rootIndex    = inputStruct.rootIndex;
data         = inputStruct.data;

groupNames = cellfun(@(x) fh(x),groupNames,'UniformOutput',false);

rootPropStruct = propsToStruct(propNames{rootIndex},propValues{rootIndex},rpa{:});
output = struct(PROP_NAME,rootPropStruct);

for iGroup = 1:length(groupIndices)
    curGroupIndex = groupIndices(iGroup);
    curChanIndices = chanIndices{iGroup};
    curChanNames   = chanNames{iGroup};
    
    curChanNames = cellfun(@(x) fh(x),curChanNames,'UniformOutput',false);
    
    x_names = propNames{curGroupIndex};
    x_values = propValues{curGroupIndex};
    groupPropStruct = propsToStruct(x_names,x_values,rpa{:});
    groupStruct = struct('name',groupNames(iGroup),PROP_NAME,groupPropStruct);
    for iChan = 1:length(curChanIndices)
        curChanIndex = curChanIndices(iChan);
        chanPropStruct = propsToStruct(propNames{curChanIndex},propValues{curChanIndex},rpa{:});
        chanStruct =  struct('name',curChanNames{iChan},PROP_NAME,chanPropStruct,...
            'data',[]);
        chanStruct.data = data{curChanIndex};
        %NOTE: I had a case statement in case the data type was a string,
        %which would change the interpretation of the struct input
        if strcmp(chanStruct.name,'name')
            error('The variable "name" for a channel is off limits, need a different conversion wrapper (probably 2)')
        end
        groupStruct.(TDMS_genvarname2(chanStruct.name,rpa{:})) = chanStruct;
    end
    output.(TDMS_genvarname2(groupStruct.name,rpa{:})) = groupStruct;
end
end

function propStruct = propsToStruct(names,values,REPLACE_STR,PREPEND_STR,ALWAYS_PREPEND)
propStruct = struct([]);
for iProp = 1:length(names)
   propStruct(1).(TDMS_genvarname2(names{iProp},REPLACE_STR,PREPEND_STR,ALWAYS_PREPEND)) = values{iProp}; 
end
end

function var_name = TDMS_genvarname2(string,options)
%GENVARNAME2: Outputs a valid variable name VARNAME
%
%   GENVARNAME2(STRING,*REPLACESTR,*PREPENDSTR,*ALWAYSPREPEND) replaces invalid
%       characters in STRING with REPLACESTR. If the first letter is not
%       a letter, or ALWAYSPREPEND is true, then PREPENDSTR is prepended
%       to the variable name
%
%   Inputs
%   -------
%   STRING         - input string to convert to safe variable name
%   *REPLACESTR    - (default '_'), character to replace invalid values with
%   *PREPENDSTR    - (default 'v'), value to prepend if first character is not
%                    a letter or ALWAYSPREPEND is true
%   *ALWAYSPREPEND - (default true), if true, alwyays adds the PREPENDSTR
%
%   EXAMPLES
%   ========================================
%   Example 1:
%       % always append is selected
%       % 'var' gets appended
%       % underscore is 
%       varName = genvarname2('RZ(1)','_','var',1)
%       varName = varRZ_1_
%   Example 2:
%       %always append is not selected
%       %first character is not numeric
%       varName = genvarname2('RZ(1)','_','var',0)
%       varName = RZ_1_
%   Example 3:
%       %always appedn is not selected
%       %since numeric appends 'var'
%       varName = genvarname2('1rack','_','var',0)
%       varName = var1rack
%
%   See also: genvarname
%
%   Copied from local genvarname2

replace_str = options.replace_str;

if length(replace_str) > 1
    error('Currently unable to replace string with lengths greater than 1')
end

if ~(isstrprop(replace_str,'alphanum') || replace_str == '_')
    error('REPLACESTR must be alphaNumeric or an underscore')
end

mask = isstrprop(string,'alphanum');
ind  = find(mask,1,'first');
string(~mask) = replaceStr; %Replaces all non-alpha numeric values with _
string = string(ind:end);

if(~isletter(string(1))) || alwaysPrepend
    if ~isempty(find(~(isstrprop(prependStr,'alphanum') | replaceStr == '_'),1))
        error('PREPENDSTR values must be alphaNumeric or an underscore')
    elseif ~isletter(prependStr(1))
        error('PREPENDSTR(1) needs to be a letter to have a valid variable name')
    end
    varName = [prependStr string];
else
    varName = string;
end
end