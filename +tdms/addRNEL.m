function addRNEL
%addRNEL  Adds RNEL functions to path
%
%   RNEL functions are functions the TDMS package depends on that are
%   normally located in the RNEL library.
%
%   This function should be run when access to the RNEL library is not
%   available.

up_dir = fileparts(fileparts(mfilename('fullpath')));

addpath(fullfile(up_dir,'RNEL_functions'));

end

