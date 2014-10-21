function in_mem_data = readLeadInFromInMemData(obj,options,fid,is_index_file)
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

%TODO: I don't think this approach is the best if not using the index
%When using a index file, the lead ins will occupy a large portion of the 
%data. When not reading from an index file, this is not the case.
if is_index_file || options.lead_in_use_strfind_approach
    %Note, this may only be faster for high segment count data
    %TODO: Add check on length ...
    h__useStrfindApproach(obj,options,in_mem_data)
    return
end

eof_position = length(in_mem_data);

%LOOP - Grab lead in data
%---------------------------------------------------
%5.5 seconds

GROWTH_SIZE   = options.lead_in_growth_size;
INIT_SIZE     = options.lead_in_init_size;
n_segs        = 1; 
next_index    = 13;
start_segment_I = zeros(1,INIT_SIZE);
start_segment_I(1) = 13; %This will be corrected later
try
    while next_index <= eof_position
        %It would be nice to get rid of the addition
        %and the if statement ...
        
%        
%7*4 bytes lead in
%7 words
%1 - TDSm 1-4
%2 - toc  5-8
%3 - version number 9 - 12
%4:5 = segment length 13-20
%6:7 = meta length 21-28
        
        n_segs = n_segs + 1;
        
        if n_segs > length(start_segment_I)
            start_segment_I = [start_segment_I zeros(1,GROWTH_SIZE)]; %#ok<AGROW>
            %seg_lengths     = [seg_lengths zeros(1,GROWTH_SIZE)]; %#ok<AGROW>
        end

        %next_index + 8  - gets to 21
        %next_index + 16 - gets to start of data
        %+16 + seg_lengths - start of next segment
        %+12 => next segment length
        
        next_index = next_index + double(typecast(in_mem_data(next_index:next_index+7),'uint64')) + 28;
        start_segment_I(n_segs) = next_index;
    end
    %NOTE: This last values is invalid
    n_segs = n_segs - 1;
catch ME
    %Then we most likely got an error from improperly parsing
    %the length data and exceeding the limits of the data
    %array we are indexing into ...
    %
    %TODO: Handle this
    error('Unhandled error case')
end

%obj.invalid_segment_found = invalid_segment_found;

start_segment_I((n_segs+1):end) = [];
start_segment_I = start_segment_I - 12; %shift back to the
%start of the segments

seg_lengths = double(sl.io.staggeredU8ToU64(in_mem_data,start_segment_I+12))';

h__populateOutput(obj,start_segment_I,in_mem_data,seg_lengths)

end

function h__useStrfindApproach(obj,options,in_mem_data) %#ok<INUSL>
%
%   This approach searches for the lead in header in the file.
%
%   Inputs:
%   -------
%
start_segment_I = strfind(in_mem_data,typecast(obj.first_word,'uint8'));

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

%This check does not work when reading from an index file ...
if obj.reading_index_file
    %Can't do an error check here, need to know the meta lengths ...
else
    if start_segment_I(1) ~= 1 || ~isequal(start_segment_I(1:end-1) + 28 + seg_lengths(1:end-1),start_segment_I(2:end))
        %TODO: Handle this ...
        %This code indicates that 'I' has matched extra instances
        %and that some of the I's are not valid and we need to filter them out
        error('JAH TODO: Write this code')
    end
end

h__populateOutput(obj,start_segment_I,in_mem_data,seg_lengths)

end

function h__populateOutput(obj,start_segment_I,in_mem_data,seg_lengths)

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