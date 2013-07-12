function readLeadInFromIndexFile(obj)
%
%
%
%
%   TODO: Finish up this code
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Might convert to using uint32 as the default
%   2) Need to handle unclosed files
%   3) Move to using input options
%   4) change 28 to variable name
%
%   ASSUMPTIONS
%   ======================================================================
%   Double works fine for byte indexing, instead of uint64
%       TODO: Add check for double overflow
%
%   FULL PATH:
%       tdms.lead_in.readLeadInFromIndexFile

%Create local reference, property access is really slow
GROWTH_SIZE = obj.options_obj.lead_in_GROWTH_SIZE;

%Read all data in at once ...
fid = obj.fid;
all_meta_data_u8 = fread(fid,[1 Inf],'*uint8'); 

%TODO: Move this out of here ...
fclose(fid);

%Approach: Assume everything is good, then 
%check afterwards whether or not it is ...

%INITIALIZATION
%-------------------------------------------------------------------------
%NOTE: For typecasting we must have data grow in columns
%or transpose later ...
lead_in_data = zeros(28,obj.options_obj.lead_in_INIT_SIZE,'uint8');
nextIndex    = 1;
nsegs        = 0;
eofPosition  = length(all_meta_data_u8);

%LOOP 
%---------------------------------------------------
%1) Grab lead in data
%2) Grab meta length
try
    while nextIndex <= eofPosition
       nsegs = nsegs + 1;

       if nsegs > size(lead_in_data,2)
           lead_in_data = [lead_in_data zeros(28,GROWTH_SIZE,'uint8')]; %#ok<AGROW>
       end

       lead_in_data(:,nsegs) = all_meta_data_u8(nextIndex:nextIndex+27);
       nextIndex    = nextIndex + 20;
       meta_length  = double(typecast(all_meta_data_u8(nextIndex:nextIndex+7),'uint64'));
       nextIndex    = nextIndex + meta_length + 8; %Lead in size
    end
catch ME
   %TODO: Most often this goes wrong because 
   %of files not being closed properly. Most often this can be found
   %by checking the flags, I have seen some instances in which it is not
   %Ideally we have an option here which allows the user to return
   %all data up until the bad segment
   rethrow(ME)
end

lead_in_data(:,nsegs+1:end) = []; %truncate overly allocated data
lead_in_flags = typecastC(lead_in_data(1:4,:),'uint32');

I_bad = find(lead_in_flags ~= obj.first_word,1);
if ~isempty(I_bad)
    error('Invalid lead in detected, handling not yet supported ...')
end

%We'll skip version # for now (9:12 => uint32)

seg_lengths   = double(typecastC(lead_in_data(13:20,:),'uint64'))';
meta_lengths  = double(typecastC(lead_in_data(21:28,:),'uint64'))';

%- All meta_starts are separated from each other by the lead in length (28)
%plus the meta_lengths of their neighbors
%- The first meta segment starts at 29, which is the lead in length plus 1
%(for 1 based indexing)
%- NOTE: The 28 is within the cumsum, not outside of it
meta_starts       = 29 + [0 cumsum(meta_lengths(1:end-1) + 28)];

meta_data = cell(1,nsegs);
for iSeg = 1:nsegs
   meta_data{iSeg} = all_meta_data_u8(meta_starts(iSeg):meta_starts(iSeg) - 1 + meta_lengths(iSeg));
end

%Final Property Assignment
%----------------------------------------------------------------
obj.data_lengths  = seg_lengths - meta_lengths;

populateRawDataStarts(obj,meta_lengths,seg_lengths)

obj.toc_masks     = typecastC(lead_in_data(5:8,:),'uint32');
obj.n_segs        = nsegs;
obj.meta_data     = meta_data;

end