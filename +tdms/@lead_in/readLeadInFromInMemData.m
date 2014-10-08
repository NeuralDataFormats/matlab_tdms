function in_mem_data = readLeadInFromInMemData(obj,options,fid)
%
%
%   readLeadInFromInMemData(obj,options,fid)
%
%   See Also:
%   tdms.lead_in.readLeadInFromDataFile
%   tdms.lead_in.readLeadInFromInMemData
%
%   IMPROVEMENT NOTES
%   =======================================================================
%   1) We could add a check for data consistency

%Yikes, we don't want to read the data here if we don't need to
%Pass this decision up ...
in_mem_data = fread(fid,[1 Inf],'*uint8');

if options.lead_in_use_strfind_approach
    %Note, this may only be faster for high segment count data
    %TODO: Add check on length ...
    h__useStrfindApproach(obj,options,in_mem_data)
    return
end


%Code below is not finished ...

eof_position = length(in_mem_data);

%LOOP - Grab lead in data
%---------------------------------------------------
%5.5 seconds

GROWTH_SIZE   = options.lead_in_growth_size;
INIT_SIZE     = options.lead_in_init_size;
n_segs_p1     = 1;
next_index    = 13;
seg_starts = zeros(1,INIT_SIZE);

try
    while next_index <= eof_position
        %It would be nice to get rid of the addition
        %and the if statement ...
        n_segs_p1 = n_segs_p1 + 1;
        
        if n_segs_p1 > length(seg_starts)
            seg_starts = [seg_starts zeros(1,GROWTH_SIZE)]; %#ok<AGROW>
        end
        
        next_index = next_index + double(typecast(in_mem_data(next_index:next_index+7),'uint64')) + 28;
        seg_starts(n_segs_p1) = next_index;
    end
    n_segs = n_segs_p1 - 1;
catch ME
    %Then we most likely got an error from improperly parsing
    %the length data and exceeding the limits of the data
    %array we are indexing into ...
    %
    %TODO: Handle this
    error('Unhandled error case')
end


obj.invalid_segment_found = invalid_segment_found;

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


meta_starts = 28 + [1 cumsum(seg_lengths(1:end-1) + 28)];

raw_meta_data = cell(1,n_segs);
for iSeg = 1:n_segs
    raw_meta_data{iSeg} = in_mem_data(meta_starts(iSeg):meta_starts(iSeg) - 1 + meta_lengths(iSeg));
end

obj.toc_masks     = typecastC(lead_in_data(5:8,:),'uint32');
obj.n_segs        = n_segs;
obj.raw_meta_data = raw_meta_data;

end

function h__useStrfindApproach(obj,options,in_mem_data) %#ok<INUSL>
%
%   This approach searches for the lead in header in the file.
%
%   Inputs:
%   -------
%
start_segment_I = strfind(in_mem_data,uint8('TDSm'));

try
    seg_lengths = double(sl.io.staggeredU8ToU64(in_mem_data,start_segment_I+12))';
catch ME
    obj.error_in_lead_in = true;
    obj.error_in_lead_in_reason = 'Lead in comes too close to end of file';
    
    %NOTE: This can be fixed by a slower check 
    %TODO: Finish this ...
    error('This bit needs to be finished ...')
end

%Error Handling
%--------------------------------------------------------------------------
%NOTE: If anything causes a problem we'll need to do some truncation ...
if start_segment_I(1) ~= 1 || ~isequal(start_segment_I(1:end-1) + 28 + seg_lengths(1:end-1),start_segment_I(2:end))
    %TODO: Handle this ...
    %This code indicates that 'I' has matched extra instances
    %and that some of the I's are not valid and we need to filter them out
    error('JAH TODO: Write this code')
end

lead_in = double(sl.io.staggeredU8ToU32(in_mem_data,start_segment_I))';

I_bad = find(lead_in ~= obj.first_word,1);
if ~isempty(I_bad)
   %TODO: Handle this case ...
   error('Case currently unhandled') 
end
%--------------------------------------------------------------------------


%Output Population
%--------------------------------------------------------------------------
n_segs        = length(start_segment_I);
obj.n_segs    = n_segs;
obj.toc_masks = double(sl.io.staggeredU8ToU32(in_mem_data,start_segment_I+4))';

meta_lengths     = double(sl.io.staggeredU8ToU32(in_mem_data,start_segment_I+20))';
meta_starts      = start_segment_I + 28;

%See obj.populateRawDataStarts instead ...
obj.data_starts  = meta_starts + meta_lengths;
obj.data_lengths = seg_lengths - meta_lengths;

raw_meta_data = cell(1,n_segs);

meta_ends = meta_starts + meta_lengths - 1;
for iSeg = 1:n_segs
   raw_meta_data{iSeg} = in_mem_data(meta_starts(iSeg):meta_ends(iSeg));
end

obj.raw_meta_data = raw_meta_data;

end