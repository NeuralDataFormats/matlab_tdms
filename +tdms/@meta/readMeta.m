function readMeta(obj)
%readMeta
%
%   NAME: tdms.meta.readMeta



%fid = obj.fid;



obj.lead_in = tdms.lead_in_array(obj.fid,obj.reading_index_file);

extractMetaInfo(obj) %Populates raw meta

raw_meta_obj  = obj.raw_meta;

%NOTE: Step 1 is finished, now onto step 2
%=========================================================================
%STEP 2, CLEANUP & VERIFICATION

[u_obj_names,u_obj_names__indices,final_id] = unique2(raw_meta_obj.obj_names);
n_unique_objs = length(u_obj_names);

getObjProps(obj,final_id,n_unique_objs);

getNPerRead(obj,final_id,n_unique_objs)

new_obj_list = obj.lead_in.new_obj_list;

%NEXT PART
%======================================================
I_new_obj_start_seg  = find(new_obj_list);
I_new_obj_end_seg_p1 = [I_new_obj_start_seg(2:end); obj.lead_in.n_segs+1];
I_new_obj_end_seg    = I_new_obj_end_seg_p1 - 1;

%NOTE: BIN_I will now define the ending segment
[~,BIN_I] = histc(obj.raw_meta.obj_seg,[I_new_obj_start_seg; obj.lead_in.n_segs+1]);

obj_seg = obj.raw_meta.obj_seg;

%NOTE: If there is a new object list for every read, then all of this
%should be 1 to 1 and can probably be skipped

%TODO: Fix this ...
BLAH = 10*length(BIN_I);
raw_obj_linear = zeros(1,BLAH);
seg_linear     = zeros(1,BLAH);

obj_has_raw_data = obj.raw_meta.obj_has_raw_data;

%In this loop we go from objects which may come in at a given segment
%and then persist for multiple segments until a new list is present,
%to explicit specification that these objects exist for every segment that
%they exist.
%i.e. you might have
%seg #      1  2  3  4
%obj 1         y
%new list            y
%In this case object 1 exists for segments 2 & 3.

%NOTE: We also need to check that a new definition of the object
%doesn't coexist with an old definition of the object 

cur_index = 0;
for iObj = 1:length(BIN_I)
    %NOTE: Would be nice to get rid of this if
    if obj_has_raw_data(iObj)
        
        %NOTE: This could all be vectorized ...
        start_seg      = obj_seg(iObj);
        end_seg        = I_new_obj_end_seg(BIN_I(iObj));
        n_segs_for_obj = end_seg-start_seg + 1;
        
        
        %Which means this could probably be vectorized
        %use cumsum
        %TODO: Check for overflow here ...
        
        raw_obj_linear(cur_index+1:cur_index+n_segs_for_obj) = iObj;
        seg_linear(cur_index+1:cur_index+n_segs_for_obj)     = start_seg:end_seg;
        cur_index = cur_index + n_segs_for_obj;
    end
end

raw_obj_linear = raw_obj_linear(1:cur_index);
seg_linear     = seg_linear(1:cur_index);

%Now we need to get instructions
%===================================================
%n bytes per segment

%A = accumarray(SUBS,VAL);
n_bytes_per_read_per_segment = accumarray(seg_linear',...
    obj.n_bytes_per_read(raw_obj_linear),[obj.lead_in.n_segs 1]);

n_reps_per_segment = n_bytes_per_read_per_segment./obj.lead_in.data_lengths;

if any(abs(n_reps_per_segment - round(n_reps_per_segment)) > 0.00001)
    %TODO: Provide more detail in error code
    error('Integer reading expected')
end

%What do we need now
%1 = for each segment, which channels are present
%represent as, start, stop in linearized array?
%NOTE: Might need to sort linearized array
%seg,obj => sort rows


return


FINAL_READ_SPECS_SIZE = 2*obj.lead_in.n_segs;
read__id          = zeros(1,FINAL_READ_SPECS_SIZE);
read__byte_start  = zeros(1,FINAL_READ_SPECS_SIZE);
read__n_values    = zeros(1,FINAL_READ_SPECS_SIZE);
read__n_bytes     = zeros(1,FINAL_READ_SPECS_SIZE);
cur_read_index    = 0;


end



%NOTE: This will eventually be needed ...
%Need to fix objects & props
function str_out = local_native2unicode(uint8_in)
STR_ENCODING = 'UTF-8';
str_out = native2unicode(uint8_in,STR_ENCODING);
end