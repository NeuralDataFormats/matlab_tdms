function createFinalIDInfo(obj)
%createFinalIDInfo(obj)
%
%   The goal of this method is to identify multiple reads from the same
%   object as belonging to one object. The only way to identify objects is
%   by their name. Instead of doing a string comparision for every object
%   definition in a segment, we collect all information, then consolidate
%   later. Specifically, we avoid a string comparision over all known
%   object names for every potentially new object, to a string sort
%   operation which in many cases (? not sure about small # objects, 
%   does minimize function calls) is much faster.
%
%   FULL PATH:
%       tdms.meta.final_id.createFinalIDInfo
%
%   See Also:
%       tdms.meta.raw

raw_meta_obj = obj.parent.raw_meta;

%Sort the raw names, there are likely duplicates
%--------------------------------------------------------------------------
[sorted_names,I_sort__raw_to_final] = sort(raw_meta_obj.raw_obj__names);

%Find the start of each unique object
%--------------------------------------------------------------------------
I_diff      = find(~strcmp(sorted_names(1:end-1),sorted_names(2:end)));
I_obj_start = [1 I_diff + 1];


%NOTE: We may eventually want this information ...
%obj.first_instance_of_final_obj = I_sort__raw_to_final(I_start);

%NOTE: This final_id is not exposed externally, but is rather to distinguish
%between unique objects

final_obj_id__sorted = zeros(1,raw_meta_obj.n_raw_objs);
final_obj_id         = zeros(1,raw_meta_obj.n_raw_objs);

%Go from:
%1 0 0 1 0 1 <= 1's indicates start of new object id
%to:
%1 1 1 2 2 3
final_obj_id__sorted(I_obj_start) = 1;
final_obj_id__sorted = cumsum(final_obj_id__sorted);

%Unsort the final objects for reference with read order
final_obj_id(I_sort__raw_to_final) = final_obj_id__sorted;

%Populate object props
%NOTE: here the object names are fixed ...
%------------------------------------------------------------
obj.final_obj_id__sorted = final_obj_id__sorted;
obj.I_sort__raw_to_final = I_sort__raw_to_final;

obj.final_obj_id         = final_obj_id;
obj.n_unique_objs        = length(sorted_names);
obj.unique_obj_names     = tdms.meta.fixNames(sorted_names(I_obj_start));
end