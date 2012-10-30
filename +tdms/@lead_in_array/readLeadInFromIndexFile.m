function readLeadInFromIndexFile(obj,fid,first_word)
%
%
%
%
%   TODO: Finish up this code
%
%   IMPROVEMENTS
%   =========================================
%   1) Might convert to using uint32 as the default
%   2) Need to handle unclosed files
%   3) Move to using input options
%   4) change 28 to variable name
%
%   ASSUMPTIONS
%   =========================================
%   Double works fine for index, instead of uint64
%       TODO: Add check for double overflow

INIT_SIZE   = 10000;
GROWTH_SIZE = 10000;

str = fread(fid,[1 Inf],'*uint8'); 

eofPosition = length(str);

%New Approach: Assume everything is good, then 
%check afterwards whether or not it is ...
curIndex = 1;

%NOTE: For typecasting we must have data grow in columns
%or transpose later ...
lead_in_data = zeros(28,INIT_SIZE,'uint8');
nsegs = 0;

while curIndex <= eofPosition
   nsegs = nsegs + 1;
   
   if nsegs > size(lead_in_data,2)
       lead_in_data = [lead_in_data zeros(28,GROWTH_SIZE,'uint8')]; %#ok<AGROW>
   end
   
   %TODO: If this ever goes wrong we need to go back and retroactively 
   %check the lead in flags ...
   
   lead_in_data(:,nsegs) = str(curIndex:curIndex+27);
   curIndex    = curIndex + 20;
   meta_length = double(typecast(str(curIndex:curIndex+7),'uint64'));
   curIndex    = curIndex + meta_length + 8; %Lead in size
    
end

    
%NOW: 
%Starts are at lead_in_start

lead_in_data(:,nsegs+1:end) = []; %truncate overly allocated data

lead_in_flags = typecastC(lead_in_data(1:4,:),'uint32');

I_bad = find(lead_in_flags ~= first_word,1);
if ~isempty(I_bad)
    error('Case not yet supported')
end

%TODO: Check this ...


obj.toc_masks     = typecastC(lead_in_data(5:8,:),'uint32');
%skip version number for now
seg_lengths   = double(typecastC(lead_in_data(13:20,:),'uint64'));
meta_lengths  = double(typecastC(lead_in_data(21:28,:),'uint64'));

%NOTE: The first meta is at 28
%The 2nd one follows 2 lead ins 2*28, not one
%NOTE: When going by indices, need to correct by factor of 1
meta_starts       = 29 + [0; cumsum(meta_lengths(1:end-1) + 28)];
obj.data_lengths  = seg_lengths - meta_lengths;
obj.data_starts   = meta_starts + meta_lengths;

meta_data = cell(1,nsegs);
for iSeg = 1:nsegs
   meta_data{iSeg} = str(meta_starts(iSeg):meta_starts(iSeg) - 1 + meta_lengths(iSeg));
end

obj.meta_starts = meta_starts;
obj.n_segs      = nsegs;
obj.meta_data   = meta_data;

end