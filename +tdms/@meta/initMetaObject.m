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

return

%Step 3: Generate corrected unique segment info
%----------------------------------------------
%- remove typecasting that was not done previously
%- update n_bytes_per_read for all non-string types
%- this will then be propogated back into the proper read order

%Step 4: Generate read information
%----------------------------------------------
n_unique_objs = obj.final_id_info.n_unique_objs;

ordered_segment_info = obj.raw_meta.ordered_segment_info;


%These will be temporary variables
final_obj__reading_channel       = false(1,n_unique_objs); %true if the
%channel should be read for a given segment

final_obj__in_read_list          = false(1,n_unique_objs);
final_obj__has_raw_data          = false(1,n_unique_objs); %This is a hold
%over from the old code. I might get rid of it. Set true if there is ever a
%specification of the channel having data.

%channel is in the read list
final_obj__info_set              = false(1,n_unique_objs);

final_obj__n_values_per_read     = zeros(1,n_unique_objs);
final_obj__n_bytes_per_read      = zeros(1,n_unique_objs);

lead_in__data_starts    = obj.lead_in.data_starts;
lead_in__data_lengths   = obj.lead_in.data_lengths;
lead_in__new_obj_list   = obj.lead_in.new_obj_list;
lead_in__is_interleaved = obj.lead_in.is_interleaved;

n_segments = obj.raw_meta.n_segments;

temp__read_order       = zeros(1,20); %Values represent final object ids
temp__read_order_count = 0;

raw_id_to_final_id_map = obj.final_id_info.raw_id_to_final_id_map;

temp_final_segment_info_ca = cell(1,n_segments);

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
    
    %TODO: Need to handle the Lazerus case:
    %- len = intmax('uint32') but in read order
    cur_seg_info = ordered_segment_info(iSeg);
    
    %get final ids of this segment
    
    seg_final_ids = raw_id_to_final_id_map(cur_seg_info.obj_id);
    
    seg_idx_data   = cur_seg_info.obj_idx_data;
    
    %TODO: Precompute these on the unique set
    seg_n_values   = double(tdms.sl.io.typecastC(seg_idx_data(3:4,:),'uint64'));
    
    %TODO: Correct this on the unique set
    seg_size_bytes = double(tdms.sl.io.typecastC(seg_idx_data(5:6,:),'uint64'));
    
    idx_lens = cur_seg_info.obj_idx_len;
    
    for iID = 1:length(seg_final_ids)
        cur_final_id = seg_final_ids(iID);
        cur_idx_len  = idx_lens(iID);
        if cur_idx_len == 0
            %same as before, runs checks

            %NOTE: # of values
            if ~final_obj__reading_channel(cur_final_id)
                final_obj__reading_channel(cur_final_id) = true;
                temp__read_order_count = temp__read_order_count + 1;
                temp__read_order(temp__read_order_count) = cur_final_id;
            end
        elseif cur_idx_len == UINT32_MAX
            %no raw data in this segment
            %
            %Is this temporary, does it come back in the next segment
            %automatically?????
            
            
            if final_obj__reading_channel(cur_final_id)
               dirty_read_list = true; 
            end
            
            final_obj__reading_channel(cur_final_id) = false;
        else
            final_obj__n_values_per_read(cur_final_id) = seg_n_values(iID);
            
            if ~final_obj__reading_channel(cur_final_id)
                final_obj__reading_channel(cur_final_id) = true;
                temp__read_order_count = temp__read_order_count + 1;
                temp__read_order(temp__read_order_count) = cur_final_id;
            end            
        end
    end
    
    %raw_data_types = cur_seg_info
    
    seg_read_order        = temp__read_order(1:temp__read_order_count);
    seg_n_values_per_read = final_obj__n_bytes_per_read(seg_read_order);
    seg_n_bytes_per_read  = final_obj__n_bytes_per_read(seg_read_order);
    if dirty_read_list
        error('Unhandled case, need to check on conversations with NI')
       keyboard %TODO: Set things to zero 
    end
    
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

function h__verifyDataTypeSame(obj)

end

%function h__fix