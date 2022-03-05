function reading_index_file = open_file(obj,filepath)
%open_file  Opens tdms or index file for reading meta data
%
%   tdms.meta.open_file(obj,filepath)

options_local = obj.options;

[tdmsPathToFile,tdmsNameOnly,fileExt] = fileparts(filepath);

if ~(strcmp(fileExt,'tdms') || strcmp(fileExt,'tdms_index'))

    
p_summary = obj.p_summary;    
    
is_index_only = strcmp(fileExt,obj.TDMS_INDEX_FILE_EXTENSION); 

p_summary.input_file_path_index_only = is_index_only;

%TODO: Check for an improper file input - not tdms or tdms_index

%Use index file if:
%------------------
%1) .tdms was passed in
%AND 2) we allow index reading - meta_USE_INDEX
%AND 3) the index file exists
%
%   OR
%
%1) only the index file was passed in
%------------------------------------------------------------------


if is_index_only
    p_summary.used_index_file = true;
    p_summary.used_index_file_reason = 'Specified filepath is index, not data file';
elseif options_local.meta__USE_INDEX
    %switch from tdms to tmds index file extension
    index_filepath = fullfile(tdmsPathToFile,[tdmsNameOnly obj.TDMS_INDEX_FILE_EXTENSION]);
    if exist(index_filepath,'file')
        %NOTE: Could throw warning if it doesn't exist ...
        filepath = index_filepath;
        p_summary.used_index_file = true;
        p_summary.used_index_file_reason = 'Matching index file exists for specified file';
    else
        p_summary.used_index_file = false;
        p_summary.used_index_file_reason = 'Corresponding index file missing, using data file';
    end
else
    p_summary.used_index_file = false;
    p_summary.used_index_file_reason = 'Option ''meta_USE_INDEX'' is false';
end

reading_index_file = p_summary.used_index_file;

%Check for file existence and open
%---------------------------------------------------------------
if ~exist(filepath,'file')
   error('Specified file does not exist:\n%s\n',filepath) 
end 

obj.fid       = fopen(filepath,'r',obj.MACHINE_FORMAT,obj.STRING_ENCODING);
obj.file_open = true; 


end