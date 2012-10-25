function nBytesByType = getNBytesByTypeArray(obj)
%getNBytesByTypeArray  
%
%   NOTE: This might need to move ...
%
%   tdms.meta.getNBytesByTypeArray
%
%   OUTPUT
%   =======================================================================
%   nBytesByType : numeric array, see explanation below
%
%Each data type has an integer id associated with it which can range from 1
%1 - 68, 0 is null and should never come up. I don't explicity test for
%this as it will throw a warning. Given the integer id, one can index into
%this array to determine the number of bytes the given type occupies per
%value.

nBytesByType        = zeros(1,68);
nBytesByType(1:10)  = [1 2 4 8 1 2 4 8 4 8];
nBytesByType(25)    = 4;
nBytesByType(26)    = 8;
nBytesByType(33)    = 1;
nBytesByType(68)    = 16;

end

