function init_obj(obj)
%
%   init_obj(obj)
%
%   Class: tdms.lead_in_array

%TODO: Delete method
%Call all of this from constructor ...


%STATUS: I need 3 separate cases
%1) Index file exists, do all in memory
%2) Index file does not exist, but file is small
%3) No Index, LARGE file

if obj.reading_index_file
    readLeadInFromIndexFile(obj)
else
    error('Unandled case')
end



end