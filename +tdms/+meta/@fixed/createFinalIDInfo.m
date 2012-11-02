function createFinalIDInfo(obj)
%createFinalIDInfo(obj)
%

raw_meta_obj = obj.raw_meta;

[sorted_names,I_sort__raw_to_final] = sort(raw_meta_obj.raw_obj__names);

I_diff  = find(~strcmp(sorted_names(1:end-1),sorted_names(2:end)));
I_start = [1 I_diff + 1];

%NOTE: We may eventually want this information ...
%obj.first_instance_of_final_obj = I_sort__raw_to_final(I_start);

final_obj_id__sorted = zeros(1,raw_meta_obj.n_raw_objs);
final_obj_id         = zeros(1,raw_meta_obj.n_raw_objs);

%Go from:
%1 0 0 1 0 <= 1's indicates start of new id
%to:
%1 1 1 2 2
final_obj_id__sorted(I_start) = 1;
final_obj_id__sorted = cumsum(final_obj_id__sorted);

%Unsort the final objects for reference with read order
final_obj_id(I_sort__raw_to_final) = final_obj_id__sorted;
n_unique_objs = length(sorted_names);

obj.final_obj_id__sorted = final_obj_id__sorted;
obj.final_obj_id         = final_obj_id;
obj.n_unique_objs        = n_unique_objs;
obj.I_sort__raw_to_final = I_sort__raw_to_final;

%Fix the object names
obj.unique_obj_names = tdms.meta.fixNames(sorted_names(I_start));
end