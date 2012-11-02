function getDataOrderEachSegment(obj)
%
%
%
%PROBLEM DESCRIPTION:
%==================================================================
%The TDMS file specifies when to start reading a new object. It does not
%EXPLICITLY specify for each object that it is present in whether or not to
%read the object. Every time a new object list is specified the previous
%object list terminates. Since we don't determine uniqueness of objects, it
%is possible that a channel is respecified without a new object list
%occuring. In this case we need to realize that the object has been
%respecified and not continue trying to read the segment until a new list.
%
%   An example is shown below.
%   Let raw objects 1,2,4,5 all represent the same final object
%   raw object 3 represents a different final obj
%   Segments  1  2  3  4  5  6  7  8
%   New List  y     y           y
%   Raw Obj   1     2        4  5
%   Raw Obj               3
%
%   In this example, we need to read using raw object 1 from segments 1 &
%   2. We need to read using raw 2 for segments 3:5. For segment 6
%   something about the object changed (generally # of samples to read) so
%   we need to read segment 6 using the instructions from raw 4. For
%   segment 7 a new list was created, so we would read segments 7 & 8 using
%   the instructions from raw object 5.
%
%   For raw object 3, it is read for segments 5 & 6. 
%
%   NOTE: The representation of raw objects is realistic here in that the
%   they are ordered by their first encounter in the file, not by channel.
%   In other words raw object 3 arrives at segment 5, before objects 4 & 5
%   in segments 6 & 7.
%
%   OUTPUTS - for the example above
%   =======================================================================
%   seg_linear     = [1 2 3 4 5 5 6 6 7 8]
%   raw_obj_linear = [1 1 2 2 2 3 3 4 5 5]
%
%   NOTE: These values will ONLY EXIST for objects with data.
%
%   See Also: 
%       tdms.meta.fixed.fixNInfo
%       
%
%   

%Local prop assignment

final_obj_id__sorted = obj.final_obj_id__sorted;
I_obj_orig           = obj.I_sort__raw_to_final;



raw_meta_obj  = obj.raw_meta;

%STEP 1: Determine the appropriate end segment for each raw object
%==========================================================================

%Find the end segments based on new lists
%The actual end segments are 1 prior to a new list, as the segment with a
%new list does not contain the old object
n_segs_p1 = obj.parent.lead_in.n_segs+1;
I_new_obj_start_seg  = find(obj.parent.lead_in.new_obj_list)'; %NOTE: Make row vector
I_new_obj_end_seg_p1 = [I_new_obj_start_seg(2:end) n_segs_p1];
I_new_obj_end_seg    = I_new_obj_end_seg_p1 - 1;

%Here we correct for a change in the object specification that occurs
%without a corresponding new object list. We sort the start segments of
%each raw object, along with its final object id. For each we determine the
%end segment that they would have if using only the new object list. If
%neighboring indices share the same final id AND the same new list id, then
%a change in the object specification has occurred, and the index to the
%left must end a segment before the segment of the index to the right. In
%the case above this would correspond to raw objects 2 & 4 sharing an end
%segment of 6, but also the same final id (value not specified).
raw_obj__seg_id__sorted = raw_meta_obj.raw_obj__seg_id(I_obj_orig);
[~,end_seg_I] = histc(raw_obj__seg_id__sorted,[I_new_obj_start_seg n_segs_p1]);

%Change if                same object id                AND      same end segment
change_end_seg_I = find(diff(final_obj_id__sorted) == 0 & diff(end_seg_I) == 0);

end_segments__sorted = I_new_obj_end_seg(end_seg_I);
if ~isempty(change_end_seg_I)
   %Grab segment of the index to the right and end at the segment before it
   end_segments__sorted(change_end_seg_I) = raw_obj__seg_id__sorted(change_end_seg_I + 1)-1;
end

%Change end segments back to the original read order, not sorted by final id
end_segments             = zeros(1,raw_meta_obj.n_raw_objs);
end_segments(I_obj_orig) = end_segments__sorted;

%STEP 2: Compute raw_obj_linear & seg_linear
%==========================================================================
start_segments     = raw_meta_obj.raw_obj__seg_id;
n_segs_for_raw_obj = end_segments - start_segments + 1;

%Filter important values by whether or not raw data is present
raw_obj_ids_with_data = find(raw_meta_obj.raw_obj__has_raw_data & obj.n_values_per_read > 0);
n_segs_for_raw_obj    = n_segs_for_raw_obj(raw_obj_ids_with_data);
start_segments        = start_segments(raw_obj_ids_with_data);

nTotalSegments = sum(n_segs_for_raw_obj);

%This replicates each data point in a vector a given amount of times:
%data: raw_obj_ids_with_data
%rep amount: n_segs_for_raw_obj
temp_indices      = false(1,nTotalSegments);

I_s = cumsum([1 n_segs_for_raw_obj(1:end-1)]);
%I_s indicates the first index of each object

temp_indices(I_s) = true;
raw_obj_linear    = raw_obj_ids_with_data(cumsum(temp_indices));

%Here we want to start at a particular value and count up
%EXAMPLE: From above
%raw         1, 2
%# segs      2, 3
%start segs  1  3 

%NOTE: I could vectorize with double cumsum, wan't all that legible or that
%much quicker ...

seg_linear = zeros(1,nTotalSegments);
cur_I = 0;
for iObj = 1:length(start_segments)
    seg_linear(cur_I+1:cur_I+n_segs_for_raw_obj(iObj)) = ... 
        start_segments(iObj):start_segments(iObj)+n_segs_for_raw_obj(iObj)-1;
    cur_I = cur_I + n_segs_for_raw_obj(iObj);
end

seg_obj_merged = [seg_linear' raw_obj_linear'];
seg_obj_merged = sortrows(seg_obj_merged);

obj.seg_id = seg_obj_merged(:,1)';
obj.obj_id = seg_obj_merged(:,2)';


