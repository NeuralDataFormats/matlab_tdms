function open_file(obj,filepath)
%
%
%   STATUS: Done, needs documentation though

[tdmsPathToFile,tdmsNameOnly,fileExt] = fileparts(filepath);
obj.is_index_only = strcmp(fileExt,obj.TDMS_INDEX_FILE_EXTENSION);

%Use index file if .tdms was passed in and we allow index reading
%and the index file exists
%------------------------------------------------------------------
if ~obj.is_index_only && obj.opt_USE_INDEX
    %switch from tdms to 
    index_filepath = fullfile(tdmsPathToFile,[tdmsNameOnly obj.TDMS_INDEX_FILE_EXTENSION]);
    if exist(index_filepath,'file')
        %NOTE: Could throw warning if it doesn't exist ...
        filepath = index_filepath;
    end
else
    opt.reading_index_file = false;
end

%Check for file existence and open
%---------------------------------------------------------------
if ~exist(filepath,'file')
   error('Specified file does not exist:\n%s\n',filepath) 
end

obj.fid = fopen(filepath,'r',obj.MACHINE_FORMAT,obj.STRING_ENCODING);


end