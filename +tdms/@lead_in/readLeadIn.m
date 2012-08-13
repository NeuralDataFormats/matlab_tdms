function lead_in_array = readLeadIn(obj,fid)

%LEAD IN TAG    - 1 word
%toc            - 1 word
%ver #          - 1 word
%seg_length     - 2 words
%meta_length    - 2 words

lead_in_array = fread(fid,7,'*uint32');
%Should check lead in here ...