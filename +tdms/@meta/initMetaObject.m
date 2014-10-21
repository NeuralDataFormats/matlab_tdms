function initMetaObject(obj)
%initMetaObject Initializes tdms.meta object
%
%   tdms.meta.initMetaObject
%
%   See Also:
%   tdms.meta.raw

%Possible Optimization:
%----------------------
%If there is a new list and the same sets of meta segments afterwards
%before a new list, as has been seen previously, we could replicate the
%final results from the previous translation.
%e.g.
%If we have the segments:
%a b c a b c a
%
%Where a b & c represent segments with instructions and 'a' starts a new
%object list, then once we translate the first 3 segments, we could
%duplicate these instructions (nearly) for generating the second set of
%segments. The only thing that would change is the data starts.

UINT32_MAX = 2^32-1;

%Step 1: Extract info from meta data
%----------------------------------------------
obj.raw_meta = tdms.meta.raw(obj);

%Step 2: Get information regarding each final object
%----------------------------------------------------
obj.final_id_info = tdms.meta.final_id_info(obj);

%Step 3: Generate corrected unique segment info
%----------------------------------------------

%JAH: Working on this function
obj.corrected_seg_info = h__createCorrectedSegmentInfo(obj);

%Step 4: Generate read information
%----------------------------------------------
n_unique_objs = obj.final_id_info.n_unique_objs;

%These will be temporary variables
final_obj__reading_channel       = false(1,n_unique_objs); %true if the
%channel should be read for a given segment

final_obj__in_read_list          = false(1,n_unique_objs); %true if the
%channel is in the read list. An object may be in the read list but may
%not be read from if data index tag specifies that the segment has no data.
%This variable helps us manage the read order of objects for a segment.

%These both are "current" values that will potentially change as the
%segments progress.
final_obj__n_values_per_read     = zeros(1,n_unique_objs);
final_obj__n_bytes_per_read      = zeros(1,n_unique_objs);

lead_in__data_starts    = obj.lead_in.data_starts;
lead_in__data_lengths   = obj.lead_in.data_lengths;
lead_in__new_obj_list   = obj.lead_in.new_obj_list;
lead_in__is_interleaved = obj.lead_in.is_interleaved;

n_segments = obj.raw_meta.n_segments;

temp__read_order       = zeros(1,20); %Values represent final object ids
temp__read_order_count = 0;

temp_final_segment_info_ca = cell(1,n_segments);

full_to_unique_seg_map = obj.raw_meta.full_to_unique_map;

corrected_segment_info = obj.corrected_seg_info;

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
            final_obj__n_values_per_read(cur_final_id) = cur_seg_info.n_values_read(iID);
            final_obj__n_bytes_per_read(cur_final_id)  = cur_seg_info.n_bytes_read(iID);
            
            if ~final_obj__reading_channel(cur_final_id)
                final_obj__reading_channel(cur_final_id) = true;
                final_obj__in_read_list(cur_final_id) = true;
                temp__read_order_count = temp__read_order_count + 1;
                temp__read_order(temp__read_order_count) = cur_final_id;
            end            
        end
    end
    
    seg_read_order        = temp__read_order(1:temp__read_order_count);
    seg_n_values_per_read = final_obj__n_values_per_read(seg_read_order);
    seg_n_bytes_per_read  = final_obj__n_bytes_per_read(seg_read_order);
    if dirty_read_list
        error('Unhandled case, need to check on conversations with NI')
       keyboard %TODO: Set things to zero 
    end
    
    %TODO: This is incorrect.
    %n_bytes_per_read is really n_bytes_per_value
    %Need to make this change ...
    %Determine how strings are handled, then make sure everything
    %follows that
    n_chunks = lead_in__data_lengths(iSeg)/sum(seg_n_bytes_per_read);
    
    if n_chunks ~= floor(n_chunks)
    	error(['The remaining data doesn''t split evently into' ...
                ' chunks, estimated # of chunks: %d'],n_chunks) 
    end
    
    fsi = tdms.meta.final_segment_info;
    fsi.read_order           = seg_read_order;
    fsi.first_byte_pointer   = lead_in__data_starts(iSeg);
    fsi.is_interleaved       = lead_in__is_interleaved(iSeg);
    fsi.n_values_per_channel = seg_n_values_per_read;
    fsi.n_bytes_per_channel  = seg_n_bytes_per_read;
    fsi.n_chunks             = n_chunks;
    
    temp_final_segment_info_ca{iSeg} = fsi;
end

obj.final_segment_info = [temp_final_segment_info_ca{:}];

return

%Step 3: Expand read instructions
%----------------------------------------------
obj.fixed_meta = tdms.meta.fixed(obj);

obj.props      = tdms.props(obj);

obj.read_info  = tdms.data.read_info(obj);

end

function corrected_seg_info = h__createCorrectedSegmentInfo(obj)
%
%
%   See Also:
%   tdms.meta.corrected_segment_info
%   tdms.meta.raw_segment_info


%- remove typecasting that was not done previously
%- update n_bytes_per_read for all non-string types
%- this will then be propogated back into the proper read order
%- Also check that n_values is 0 for anything with no data

raw_meta = obj.raw_meta;
final_id_info = obj.final_id_info;

unique_segment_info = raw_meta.unique_segment_info;

%JAH: At this point

n_unique_segments = length(unique_segment_info);

temp_ca = cell(1,n_unique_segments);

temp_n_read_values = [unique_segment_info.unprocessed_n_read_values];
temp_n_size_bytes  = [unique_segment_info.unprocessed_n_read_bytes];

fixed_n_read_values = tdms.sl.io.typecastC(temp_n_read_values,'uint64');
fixed_n_size_bytes  = tdms.sl.io.typecastC(temp_n_size_bytes,'uint64');


raw_to_final_id_map = final_id_info.raw_id_to_final_id_map;

mask = fixed_n_size_bytes == 0;
fixed_n_size_bytes(mask) = final_id_info.default_byte_size(raw_to_final_id_map(mask));


has_raw_data = final_id_info.haw_raw_data';

for iSeg = 1:n_unique_segments

    cur_raw_segment_info = unique_segment_info(iSeg);
    
    temp = tdms.meta.corrected_segment_info;

    temp.first_seg_id  = cur_raw_segment_info.first_seg_id;
    
    raw_obj_ids = cur_raw_segment_info.obj_id;
    
    temp.final_obj_ids = raw_to_final_id_map(raw_obj_ids);
    temp.n_bytes_read  = fixed_n_size_bytes(raw_obj_ids);
    temp.n_values_read = fixed_n_read_values(raw_obj_ids);
    temp.idx_len = cur_raw_segment_info.obj_idx_len;
    
    temp_ca{iSeg} = temp;
    
    local_has_raw_data = has_raw_data(temp.final_obj_ids);
    
    if any(~local_has_raw_data & temp.n_values_read ~= 0)
       error('Some object with values to read doesn''t have raw data') 
    end
end

corrected_seg_info = [temp_ca{:}];
end
