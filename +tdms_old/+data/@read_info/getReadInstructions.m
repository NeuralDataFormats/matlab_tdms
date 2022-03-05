function getReadInstructions(obj)
%
%   TODO: Finish documentation
%

%This value determines if we've made an error in processing
%the read instructions if the length of our data (in bytes) divided by the # of bytes
%we are supposed to read through a single pass, doesn't come out to an
%integer. As an example, if our data length was 10 bytes, and each read we
%were supposed to read 6, 10/6 is not an integer, so this is an error.
%abs(10/6 - round(10/6)) > INTEGER_EPS, thus error
INTEGER_EPS = 0.000001;



%Quicker property references:
%----------------------------------------------------------------
fixed_meta_obj   = obj.parent.fixed_meta;
seg_id           = fixed_meta_obj.seg_id;
obj_id           = fixed_meta_obj.obj_id;
n_bytes_per_read__fixed = fixed_meta_obj.n_bytes_per_read__fixed;
n_values_per_read__fixed = fixed_meta_obj.n_values_per_read__fixed;

lead_in_obj      = obj.parent.lead_in;
data_lengths     = lead_in_obj.data_lengths;
data_starts      = lead_in_obj.data_starts;

final_id_obj     = obj.parent.final_ids;
final_obj_ids    = final_id_obj.final_obj_id;

%Some initial parsing
%----------------------------------------------------------------
seg_starts_I   = [1 find(diff(seg_id) ~= 0) + 1];
seg_ends_I     = [seg_starts_I(2:end)-1 length(seg_id)];
n_objs_per_seg = seg_ends_I - seg_starts_I + 1;
unique_seg_ids = seg_id(seg_starts_I); %NOTE we are only reading from 
%segments that have data

local__data_lengths      = data_lengths(unique_seg_ids);
local__n_bytes_per_read  = n_bytes_per_read__fixed(obj_id);
local__n_values_per_read = n_values_per_read__fixed(obj_id);
local__seg_data_starts   = data_starts(unique_seg_ids);


%NOTE: Input 1 must be column vector, sz must be [N 1]
n_bytes_per_read_per_segment = accumarray(seg_id',local__n_bytes_per_read,[lead_in_obj.n_segs 1])';
n_reps_per_segment           = local__data_lengths./n_bytes_per_read_per_segment(unique_seg_ids);

if any(abs(n_reps_per_segment - round(n_reps_per_segment)) > INTEGER_EPS)
    %TODO: Provide more detail in error code
    error('Integer reading expected')
end

n_reads_per_segment = n_objs_per_seg.*n_reps_per_segment;
n_total_reads       = sum(n_reads_per_segment);

%Initialization ---------------------------------------
read__obj_id         = zeros(1,n_total_reads);
read__byte_start     = zeros(1,n_total_reads);
read__n_values       = zeros(1,n_total_reads);
read__n_bytes        = zeros(1,n_total_reads);


cur_I = 0;
for iSeg = 1:length(seg_starts_I)
   cur_start_I    = seg_starts_I(iSeg);
   cur_end_I      = seg_ends_I(iSeg);
   
   %Byte starts for reading data in this segment
   cur_data_start = local__seg_data_starts(iSeg);
   
   %Objects to read in this segment, ordered in read order
   cur_obj_ids         = obj_id(cur_start_I:cur_end_I); 
   
   cur_bytes_per_read  = local__n_bytes_per_read(cur_start_I:cur_end_I);
   cur_values_per_read = local__n_values_per_read(cur_start_I:cur_end_I);
   cur_n_reps          = n_reps_per_segment(iSeg);
   cur_n_reads         = n_reads_per_segment(iSeg);
   
   read__obj_id(cur_I+1:cur_I+cur_n_reads)     = repmat_quick(cur_obj_ids,cur_n_reps);
   temp = repmat_quick(cur_bytes_per_read,cur_n_reps);
   read__n_bytes(cur_I+1:cur_I+cur_n_reads)    = temp;
   read__byte_start(cur_I+1:cur_I+cur_n_reads) = cur_data_start + [0 cumsum(temp(1:end-1))]; 
   read__n_values(cur_I+1:cur_I+cur_n_reads)   = repmat_quick(cur_values_per_read,cur_n_reps);
   
   cur_I = cur_I + cur_n_reads;
end

%NOTE: Need to now go from raw to final ...

obj.obj_id     = final_obj_ids(read__obj_id);
obj.byte_start = read__byte_start;
obj.n_values   = read__n_values;
obj.n_bytes    = read__n_bytes;

end

function output = repmat_quick(row_vector,N)
   temp   = (1:size(row_vector,2))';
   output = row_vector(1,temp(:,ones(1,N)));
end