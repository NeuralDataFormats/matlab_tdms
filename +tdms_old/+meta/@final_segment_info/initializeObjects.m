function objs = initializeObjects(meta_obj)
%
%   Inputs:
%   -------
%   meta_obj : tdms.meta
%   

%Inputs
%---------------------------------------
raw_meta      = meta_obj.raw_meta;
final_id_info = meta_obj.final_id_info;
%----------------------------------------

%TODO: Ideally we would pass in the things that are needed rather than
%just a handle to the meta_obj

UINT32_MAX = 2^32-1;


%Step 4: Generate read information
%----------------------------------------------
n_unique_objs = meta_obj.final_id_info.n_unique_objs;

%These will be temporary variables
final_obj__reading_channel       = false(1,n_unique_objs); %true if the
%channel should be read for a given segment

final_obj__in_read_list          = false(1,n_unique_objs); %true if the
%channel is in the read list. An object may be in the read list but may
%not be read from if data index tag specifies that the segment has no data.
%This variable helps us manage the read order of objects for a segment.

%These are "current" values that will potentially change as the
%segments progress.
final_obj__n_values_per_read = zeros(1,n_unique_objs);
final_obj__n_bytes_per_read  = zeros(1,n_unique_objs);

%This doesn't change, but we'll remove the extra referencing ...
final_obj__n_bytes_per_value = meta_obj.final_id_info.default_byte_size;

lead_in__data_starts    = meta_obj.lead_in.data_starts;
lead_in__data_lengths   = meta_obj.lead_in.data_lengths;
lead_in__new_obj_list   = meta_obj.lead_in.new_obj_list;
lead_in__is_interleaved = meta_obj.lead_in.is_interleaved;

n_segments = meta_obj.raw_meta.n_segments;

temp__read_order       = zeros(1,20); %Values represent final object ids
temp__read_order_count = 0;

temp_final_segment_info_ca = cell(1,n_segments);

full_to_unique_seg_map = meta_obj.raw_meta.full_to_unique_map;

corrected_segment_info = meta_obj.corrected_seg_info;

for iSeg = 1:n_segments
    
    dirty_read_list = false;
    
    if lead_in__new_obj_list(iSeg)
        if temp__read_order_count ~= 0
            %Set reading of objects to false
            final_obj__reading_channel(temp__read_order(1:temp__read_order_count)) = false;
            final_obj__in_read_list(temp__read_order(1:temp__read_order_count)) = false;
        end
        temp__read_order_count = 0;
    end
    
    cur_seg_info  = corrected_segment_info(full_to_unique_seg_map(iSeg));
    
    seg_final_ids = cur_seg_info.final_obj_ids;
    idx_lens      = cur_seg_info.idx_len;
    
    %TODO: handle adding final_obj__in_read_list
    for iID = 1:length(seg_final_ids)
        cur_final_id = seg_final_ids(iID);
        cur_idx_len  = idx_lens(iID);
        if cur_idx_len == 0
            %same as before
            if ~final_obj__reading_channel(cur_final_id)
                final_obj__reading_channel(cur_final_id) = true;
                temp__read_order_count = temp__read_order_count + 1;
                temp__read_order(temp__read_order_count) = cur_final_id;
            end
        elseif cur_idx_len == UINT32_MAX
            %no raw data in this segment
            
            if final_obj__reading_channel(cur_final_id)
                %Is this temporary, does it come back in the next segment
                %automatically?????
                dirty_read_list = true;
                final_obj__reading_channel(cur_final_id) = false;
            end
        else
            %Normally this section will not run (at least for tdms v2)
            
            cur_n_values_per_read = cur_seg_info.n_values_per_read(iID);
            
            final_obj__n_values_per_read(cur_final_id) = cur_n_values_per_read;
            final_obj__n_bytes_per_read(cur_final_id)  = cur_seg_info.n_bytes_per_read(iID);
            
            if cur_n_values_per_read == 0
                %Technically we should check the data type as this is only
                %for strings
                final_obj__n_bytes_per_read(cur_final_id)  = cur_seg_info.n_bytes_read(iID);
            else
                final_obj__n_bytes_per_read(cur_final_id) = cur_n_values_per_read*final_obj__n_bytes_per_value(cur_final_id);
            end
            
            if ~final_obj__reading_channel(cur_final_id)
                final_obj__reading_channel(cur_final_id) = true;
                final_obj__in_read_list(cur_final_id) = true;
                temp__read_order_count = temp__read_order_count + 1;
                temp__read_order(temp__read_order_count) = cur_final_id;
            end
        end
    end
    
    if temp__read_order_count == 0
        %Do we want to create a final segment info????
        continue
    end
    
    seg_read_order        = temp__read_order(1:temp__read_order_count);
    seg_n_values_per_read = final_obj__n_values_per_read(seg_read_order);
    seg_n_bytes_per_read  = final_obj__n_bytes_per_read(seg_read_order);
    if dirty_read_list
        error('Unhandled case, need to check on conversations with NI')
        keyboard %TODO: Set things to zero
    end
    
    n_chunks = lead_in__data_lengths(iSeg)/sum(seg_n_bytes_per_read);
    
    %TODO: It seems like if 'n_chunks' is less than 1, then a correction is
    %made to read as much data as possible
    if n_chunks ~= floor(n_chunks)
        error(['The remaining data doesn''t split evently into' ...
            ' chunks, estimated # of chunks: %d'],n_chunks)
    end
    
    fsi = tdms.meta.final_segment_info;
    fsi.seg_id               = iSeg;
    fsi.read_order           = seg_read_order;
    fsi.first_byte_pointer   = lead_in__data_starts(iSeg);
    fsi.is_interleaved       = lead_in__is_interleaved(iSeg);
    fsi.n_values_per_read    = seg_n_values_per_read;
    fsi.n_bytes_per_read     = seg_n_bytes_per_read;
    fsi.n_chunks             = n_chunks;
    
    temp_final_segment_info_ca{iSeg} = fsi;
end

objs = [temp_final_segment_info_ca{:}];

end