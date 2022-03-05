function corrected_seg_info = initializeObjects(meta_obj)
%
%
%   corrected_seg_info = tdms.meta.corrected_segment_info.initializeObjects(meta_obj);
%
%   This function:
%   - implements typecasting that was not done previously
%   - transitions from the raw ids to final ids
%   - 
%   - Also check that n_values is 0 for anything with no data
%
%   Inputs:
%   -------
%   meta_obj : tdms.meta
%   
%
%
%
%   See Also:
%   tdms.meta.corrected_segment_info
%   tdms.meta.raw_segment_info

%TODO: Ideally we would pass in the things that are needed rather than
%just a handle to the meta_obj

%Inputs
%---------------------------------------
raw_meta      = meta_obj.raw_meta;
final_id_info = meta_obj.final_id_info;
%----------------------------------------

unique_segment_info = raw_meta.unique_segment_info;

n_unique_segments = length(unique_segment_info);

temp_ca = cell(1,n_unique_segments);

temp_n_read_values = [unique_segment_info.unprocessed_n_read_values];
temp_n_size_bytes  = [unique_segment_info.unprocessed_n_read_bytes];

fixed_n_values_per_read = tdms.sl.io.typecastC(temp_n_read_values,'uint64');
fixed_n_bytes_per_read  = tdms.sl.io.typecastC(temp_n_size_bytes,'uint64');

raw_to_final_id_map = final_id_info.raw_id_to_final_id_map;

has_raw_data = final_id_info.haw_raw_data';

for iSeg = 1:n_unique_segments

    cur_raw_segment_info = unique_segment_info(iSeg);
    
    temp = tdms.meta.corrected_segment_info;

    temp.first_seg_id  = cur_raw_segment_info.first_seg_id;
    
    raw_obj_ids = cur_raw_segment_info.obj_id;
    
    temp.final_obj_ids     = raw_to_final_id_map(raw_obj_ids);
    temp.n_bytes_per_read  = fixed_n_bytes_per_read(raw_obj_ids);
    temp.n_values_per_read = fixed_n_values_per_read(raw_obj_ids);
    temp.idx_len = cur_raw_segment_info.obj_idx_len;
    
    temp_ca{iSeg} = temp;
    
    local_has_raw_data = has_raw_data(temp.final_obj_ids);
    
    if any(~local_has_raw_data & temp.n_values_per_read ~= 0)
       error('Some object with values to read doesn''t have raw data') 
    end
end

corrected_seg_info = [temp_ca{:}];
end