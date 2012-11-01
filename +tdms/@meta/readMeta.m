function readMeta(obj)
%readMeta
%
%   NAME: tdms.meta.readMeta


%Read the lead in information 
%-----------------------------------------------
%TODO: Rename to lead_in once other class has been cleared
obj.lead_in = tdms.lead_in_array(obj);

%TODO: Move method to constructor ...
extractMetaInfo(obj) %Populates raw meta

raw_meta_obj  = obj.raw_meta;



obj.fixed_meta = tdms.meta.fixed(obj);



%Property Population --------------------------------------------------
getObjProps(obj,final_obj_id,n_unique_objs);




[seg_linear,raw_obj_linear] = getDataReadOrderEachSegment(obj,final_obj_id__sorted,I_obj_orig);


%n_values_linear = obj.n_values_per_read(raw_obj_linear);

%Now we need to get instructions
%===================================================
%n bytes per segment

%A = accumarray(SUBS,VAL);
n_bytes_per_read_per_segment = accumarray(seg_linear',...
    obj.n_bytes_per_read(raw_obj_linear),[obj.lead_in.n_segs 1]);

n_reps_per_segment = obj.lead_in.data_lengths./n_bytes_per_read_per_segment;

%TODO: Make 0.0001 a CONST ABOVE
if any(abs(n_reps_per_segment - round(n_reps_per_segment)) > 0.00001)
    %TODO: Provide more detail in error code
    error('Integer reading expected')
end

%What do we need now
%1 = for each segment, which channels are present
%represent as, start, stop in linearized array?
%NOTE: Might need to sort linearized array


%seg,obj => sort rows

if any(n_reps_per_segment > 1)
    keyboard
end

n_total_reads = sum(n_reps_per_segment(seg_linear));

%What about interleaved data ???????
%When would we ever have multiple reps for interleaved data?????
%Same byte start????
%read__is_interleaved = false(1,n_total_reads);

seg_obj_matrix = [seg_linear' raw_obj_linear'];
seg_obj_matrix = sortrows(seg_obj_matrix);


seg_starts     = [1 find(diff(seg_obj_matrix(:,1)) ~= 0)+1];
seg_ends       = [seg_starts(2:end)-1 size(seg_obj_matrix,1)];
n_objs_per_seg = seg_ends - seg_starts + 1;
n_reps_all     = n_reps_per_segment(seg_obj_matrix(seg_starts,1));

bytes_per_obj  = raw_meta_obj.

%TODO: Take into account objects which "have data" but have n_values = 0

for iSeg = 1:length(seg_starts)
   n_reps = n_reps_all(iSeg);
    
    
end

read__obj_id         = zeros(1,n_total_reads);
read__byte_start     = zeros(1,n_total_reads);
read__n_values       = zeros(1,n_total_reads);
read__n_bytes        = zeros(1,n_total_reads);

cur_read_index       = 0;


end



%NOTE: This will eventually be needed ...
%Need to fix objects & props
function str_out = local_native2unicode(uint8_in)
STR_ENCODING = 'UTF-8';
str_out = native2unicode(uint8_in,STR_ENCODING);
end