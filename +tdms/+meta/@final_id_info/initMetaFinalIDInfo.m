function initMetaFinalIDInfo(obj)
%
%   tdms.meta.final_id.initMetaFinalIDInfo
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
%       
%
%   See Also:
%       tdms.meta.raw

raw_meta = obj.parent.raw_meta;

unique_segment_info = raw_meta.unique_segment_info;

[sorted_names,I_sort__raw_to_final] = sort([unique_segment_info.obj_names]);

%Find transitions in the names
I_diff      = find(~strcmp(sorted_names(1:end-1),sorted_names(2:end)));
I_obj_start = [1 I_diff + 1];

%I_obj_end = [I_diff length(sorted_names)]
%generate a vector that identifies the object id for each
%1 1 1 1 2 2 3 3 3 etc
%generate another vector that identifies the index in each object
%1 2 3 4 1 2 1 2 3
%
%Bring these into the final order via I_sort__raw_to_final
%
%Then loop through by start and end to get a cell array

%We have starts, now we want to identify each element that is the same as
%being such:
%i.e., consider a case of letters instead of names
%
%a a a c c d d d <- sorted names
%1 0 0 1 0 1 1 1 <- 1 indicates start of a new letter
%                   or in reality a new channel name
%1 1 1 2 2 3 3 3 <- what we want:
%                   - indices can be unsorted back to the original locations
%                   i.e. the raw object id
%                   - values represent the final ids

final_obj_id__sorted = zeros(1,raw_meta.n_raw_objs);
final_obj_id__sorted(I_obj_start) = 1;
final_obj_id__sorted = cumsum(final_obj_id__sorted);


obj.raw_id_to_final_id_map = zeros(1,raw_meta.n_raw_objs);
%Unsort the final objects for reference with read order
obj.raw_id_to_final_id_map(I_sort__raw_to_final) = final_obj_id__sorted;

%Some extra properties to populate
obj.n_unique_objs = length(I_obj_start);
obj.unique_obj_names = tdms.meta.fixNames(sorted_names(I_obj_start));



end