function readLeadInFromIndexFile(obj,options,fid)
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
%   tdms.lead_in.readLeadInFromIndexFile
%
%   See Also:
%   tdms.lead_in.readLeadInFromDataFile
%   tdms.lead_in.readLeadInFromInMemData

GROWTH_SIZE = options.lead_in_growth_size;
INIT_SIZE   = options.lead_in_init_size;

%Read all data in at once ...
all_meta_data_u8 = fread(fid,[1 Inf],'*uint8');

%Approach: Assume everything is good, then check afterwards whether or not it is ...

%INITIALIZATION
%-------------------------------------------------------------------------
%NOTE: For typecasting we must have data grow in columns
%or transpose later .... The initialization is a guess size. We'll truncate
%later.
lead_in_data = zeros(28,INIT_SIZE,'uint8');
next_index   = 1;
n_segs       = 0;
eof_position = length(all_meta_data_u8);

%LOOP - Grab lead in data
%---------------------------------------------------
try
    while next_index <= eof_position
       n_segs = n_segs + 1;

       %Expand data if necessary
       if n_segs > size(lead_in_data,2)
           lead_in_data = [lead_in_data zeros(28,GROWTH_SIZE,'uint8')]; %#ok<AGROW>
       end

       lead_in_data(:,n_segs) = all_meta_data_u8(next_index:next_index+27);
       meta_length  = double(typecast(lead_in_data(21:28,n_segs),'uint64'));
       next_index   = next_index + 28 + meta_length;
    end
catch ME
   rethrow(ME) 
   %TODO: Most often this goes wrong because 
   %of files not being closed properly. Most often this can be found
   %by checking the flags, I have seen some instances in which it is not
   %Ideally we have an option here which allows the user to return
   %all data up until the bad segment
   
end

%Consistent code: move to helper function ...
%--------------------------------------------------------------------------
lead_in_data(:,n_segs+1:end) = []; %truncate overly allocated data
lead_in_flags = typecastC(lead_in_data(1:4,:),'uint32');

I_bad = find(lead_in_flags ~= obj.first_word,1);
if ~isempty(I_bad)
    %TODO: options_local.read_file_until_error
    error('Invalid lead in detected, handling not yet supported ...')
end

%We'll skip version # for now (9:12 => uint32)

seg_lengths   = double(typecastC(lead_in_data(13:20,:),'uint64'))';
meta_lengths  = double(typecastC(lead_in_data(21:28,:),'uint64'))';
%--------------------------------------------------------------------------


%- All meta_starts are separated from each other by the lead in length (28)
%plus the meta_lengths of their neighbors
%- The first meta segment starts at 29, which is the lead in length plus 1
%(for 1 based indexing)
%- NOTE: The 28 is within the cumsum, not outside of it since we need to
%include a lead in length for every segment
meta_starts       = 28 + [1    cumsum(meta_lengths(1:end-1) + 28)   ];


raw_meta_data = cell(1,n_segs);
for iSeg = 1:n_segs
   raw_meta_data{iSeg} = all_meta_data_u8(meta_starts(iSeg):meta_starts(iSeg) - 1 + meta_lengths(iSeg));
end

%Final Property Assignment
%----------------------------------------------------------------
obj.data_lengths  = seg_lengths - meta_lengths;

populateRawDataStarts(obj,meta_lengths,seg_lengths)

obj.toc_masks     = typecastC(lead_in_data(5:8,:),'uint32');
obj.n_segs        = n_segs;
obj.raw_meta_data = raw_meta_data;

end