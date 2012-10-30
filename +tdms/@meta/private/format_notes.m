%FORMAT
%# of objects in segment - uint32
%   => NOTE, this could be vectorized ...
%
%
%OBJECTS
%path  - string - format
%index_length - uint32
%   => What does this mean?
%   NOTE: special values are:
%   0 - same as last time
%   MAX_INT - no raw data
%
%   %Normally length is 20, might be 28 for strings
%   4  - length    - uint32 (already read)
%   8  - data type - uint32
%   12 - dimension - uint32 
%   20 - n_values  - uint64
%   28 - size_in_bytes - uint64  (NOTE: only for strings)
%       
%
%n_properties - uint32
%
%   NOTE: 
%   name - string
%   date_type
%   value