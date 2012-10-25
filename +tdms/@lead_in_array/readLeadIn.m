function [lead_in_array,lengths] = readLeadIn(obj,fid,first_word)
%
%
%   KNOWN CALLERS:
%       tdms.lead_in_array.readLeadIn

%LEAD IN TAG    - 1 word
%toc            - 1 word
%ver #          - 1 word
%seg_length     - 2 words
%meta_length    - 2 words

%NOTE: Trying not to use this function
%Newer code:
%   readLeadInFromIndexFile


lead_in_array = fread(fid,3,'*uint32');
lengths       = fread(fid,2,'uint64');

%Should check lead in here ...

if lead_in_array(1) ~= first_word
    error('Unexpected lead in, either error or in processing or file')
end