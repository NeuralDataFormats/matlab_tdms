function in_mem_data = readLeadInFromInMemData(obj,options,fid)
%
%
%   readLeadInFromInMemData(obj,options,fid)
%
%   See Also:
%   tdms.lead_in.readLeadInFromDataFile
%   tdms.lead_in.readLeadInFromIndexFile
%   tdms.lead_in.readLeadInFromInMemData
%
%   IMPROVEMENT NOTES
%   =======================================================================
%   1) We could add a check for data consistency

in_mem_data = fread(fid,[1 Inf],'*uint8');

%Common innitialization code
%------------------------------------------------
GROWTH_SIZE = options.lead_in_growth_size;
INIT_SIZE   = options.lead_in_init_size;

lead_in_data  = zeros(28,INIT_SIZE,'uint8');
n_segs_p1     = 1;
invalid_segment_found = false;
next_index    = 1;
%-----------------------------------------------------

eof_position = length(in_mem_data);

%LOOP - Grab lead in data
%---------------------------------------------------

seg_starts = zeros(1,INIT_SIZE);
done = false;
while next_index <= eof_position
    %??? Is it possible to get rid of the if statement
    %and the plus statement?
    %Some for loop ...
    n_segs_p1 = n_segs_p1 + 1;

    if n_segs_p1 > length(seg_starts);
        seg_starts = [seg_starts zeros(1,GROWTH_SIZE)]; %#ok<AGROW>
    end

    try
        seg_starts(n_segs_p1) = next_index + double(typecast(in_mem_data(next_index+12:next_index+19),'uint64')) + 28;
        next_index = seg_starts(n_segs_p1);
    catch ME
        %Then we most likely got an error from improperly parsing
        %the length data and exceeding the limits of the data
        %array we are indexing into ...
    end
    
end
n_segs = n_segs_p1 - 1;

%Grab lead in data

return

lead_in_flag_u8 = zeros(n_segs,4,'uint8')

% try
%     while next_index <= eof_position
%         n_segs = n_segs + 1;
%         
%         %Expand data if necessary
%         if n_segs > size(lead_in_data,2)
%             lead_in_data = [lead_in_data zeros(28,GROWTH_SIZE,'uint8')]; %#ok<AGROW>
%         end
%         
%         lead_in_data(:,n_segs) = in_mem_data(next_index:next_index+27);
%         seg_length = double(typecast(lead_in_data(13:20,n_segs),'uint64'));
%         next_index = next_index + 28 + seg_length;
%     end
% catch ME
%     rethrow(ME)
%     % if invalid_segment_found
%     % if options.read_file_until_error
%     %
%     % else
%     %
%     % end
%     % end
% end

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