function open_file(obj,filepath)
%open_file  Opens tdms or index file for reading meta data
%
%   open_file(obj,filepath)
%
%   FULL PATH:
%       tdms.meta.open_file

options_obj = obj.options_obj;

[tdmsPathToFile,tdmsNameOnly,fileExt] = fileparts(filepath);
obj.is_index_only = strcmp(fileExt,obj.TDMS_INDEX_FILE_EXTENSION);

%Use index file if:
%1) .tdms was passed in
%AND 2) we allow index reading - meta_USE_INDEX
%AND 3) the index file exists
%
%   OR
%
%1) only the index file was passed in
%------------------------------------------------------------------
if obj.is_index_only
    obj.reading_index_file = true;
    obj.index_vs_data_reason = 'Specified filepath is index, not data file';
elseif options_obj.meta__USE_INDEX
    %switch from tdms to tmds index file extension
    index_filepath = fullfile(tdmsPathToFile,[tdmsNameOnly obj.TDMS_INDEX_FILE_EXTENSION]);
    if exist(index_filepath,'file')
        %NOTE: Could throw warning if it doesn't exist ...
        filepath = index_filepath;
        obj.reading_index_file = true;
        obj.index_vs_data_reason = 'Matching index file exists for specified file';
    else
        obj.reading_index_file = false;
        obj.index_vs_data_reason = 'Corresponding index file missing, using data file';
    end
else
    obj.reading_index_file = false;
    obj.index_vs_data_reason = 'Option ''meta_USE_INDEX'' is false';
end

%Check for file existence and open
%---------------------------------------------------------------
if ~exist(filepath,'file')
   error('Specified file does not exist:\n%s\n',filepath) 
end 

obj.fid       = fopen(filepath,'r',obj.MACHINE_FORMAT,obj.STRING_ENCODING);
obj.file_open = true; 


end