function open_file(obj,filepath)
%open_file  Opens tdms or index file for reading meta data
%
%   open_file(obj,filepath)
%
%   IMPROVEMENT
%   ======================================================
%   1) Allow throwing a warning by default or not if the index file
%   is not present for reading from
%
%   POPULATES:
%   ======================================================
%   .is_index_only
%   .fid 
%   .reading_index_file

[tdmsPathToFile,tdmsNameOnly,fileExt] = fileparts(filepath);
obj.is_index_only = strcmp(fileExt,obj.TDMS_INDEX_FILE_EXTENSION);

%Use index file if:
%1) .tdms was passed in
%AND 2) we allow index reading - obj.opt_USE_INDEX
%AND 3) the index file exists
%
%   OR
%
%1) only the index file was passed in
%------------------------------------------------------------------

if obj.is_index_only
    obj.reading_index_file = true;
elseif obj.opt_USE_INDEX
    %switch from tdms to tmds index file extension
    index_filepath = fullfile(tdmsPathToFile,[tdmsNameOnly obj.TDMS_INDEX_FILE_EXTENSION]);
    if exist(index_filepath,'file')
        %NOTE: Could throw warning if it doesn't exist ...
        filepath = index_filepath;
        obj.reading_index_file = true;
    else
        obj.reading_index_file = false;
    end
else
    obj.reading_index_file = false;
end

%Check for file existence and open
%---------------------------------------------------------------
if ~exist(filepath,'file')
   error('Specified file does not exist:\n%s\n',filepath) 
end


obj.fid = fopen(filepath,'r',obj.MACHINE_FORMAT,obj.STRING_ENCODING);


end