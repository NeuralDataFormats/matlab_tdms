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
%   See Also:
%       tdms.meta.raw


%TODO: This whole file needs to be broken up into subfunctions that are
%just a bit cleaner

UINT32_MAX = 2^32-1;

raw_meta = obj.parent.raw_meta;

unique_segment_info = raw_meta.unique_segment_info;

[sorted_names,I_sort__raw_to_final] = sort([unique_segment_info.obj_names]);

%Find transitions in the names
I_diff      = find(~strcmp(sorted_names(1:end-1),sorted_names(2:end)));
I_obj_start = [1 I_diff + 1];

raw_obj_ids = [unique_segment_info.obj_id];

%TODO: Come up with nice name for this ..., move to helper
%This will be useful later
%--------------------------------------
obj.final_to_raw_id_map = raw_obj_ids(I_sort__raw_to_final);
obj.I_start__raw_obj_ids = I_obj_start;
obj.I_end__raw_obj_ids = [I_diff length(sorted_names)];
%---------------------------------------------------------


final_obj_id__sorted = zeros(1,raw_meta.n_raw_objs);
final_obj_id__sorted(I_obj_start) = 1;
final_obj_id__sorted = cumsum(final_obj_id__sorted);

obj.raw_id_to_final_id_map = zeros(1,raw_meta.n_raw_objs);
%Unsort the final objects for reference with read order
obj.raw_id_to_final_id_map(I_sort__raw_to_final) = final_obj_id__sorted;

%Populate the properties that are by final objects
%Also check for unexpected specifications
obj.n_unique_objs = length(I_obj_start);
obj.unique_obj_names = tdms.meta.fixNames(sorted_names(I_obj_start));



%TODO: Finish this code:
%------------------------------------
%1) populate data types
%     - a data type can be its given value or not specified
%       if its idx_len is 0 (or intmax('uint32'), meaning that a previous 
%       value should be used
%2) Verify that any 'use previous' specification follows a valid
%   specification.
%3) Set default byte size
%4) Set has raw data ????

temp_data_types = [unique_segment_info.data_type];

final_obj__data_type = zeros(1,obj.n_unique_objs,'uint32');

idx_lens = [unique_segment_info.obj_idx_len];

I_start = obj.I_start__raw_obj_ids;
I_end   = obj.I_end__raw_obj_ids;
final_to_raw_map = obj.final_to_raw_id_map;

final_obj__has_raw_data = true(1,obj.n_unique_objs);
for iObj = 1:length(I_start)
   temp_map = final_to_raw_map(I_start(iObj):I_end(iObj));
   obj_data_types = temp_data_types(temp_map);
   obj_idx_lens = idx_lens(temp_map);
   
   %TODO: This mess of code needs to be cleaned up
   %----------------------------------------------
   I_data_type = 1;
   
   I_previous = find(obj_idx_lens == 0,1);
   if ~isempty(I_previous)
      %NOTE: If I_previous is empty, then we don't need to check
      %that the 'use previous' specification is valid because its never
      %been used for this channel
      if I_previous == 1
          error('Can''t ''use previous specification'' the first time')
      elseif obj_idx_lens(1) == UINT32_MAX
          I_data_type = find(obj_idx_lens~= UINT32_MAX,1);
          if isempty(I_data_type)
              
              %Check that no values are ever specified
              %i.e. check n_values_per_read
              final_obj__has_raw_data(iObj) = false;
              error('Unhandled case')
          elseif I_data_type > I_previous
              error('Write proper error message')
          end
      %else
      %     - then the first value has instructions for reading data
      %       so 'use previous specification' is valid
      end
   elseif obj_idx_lens(1) == UINT32_MAX
       final_obj__has_raw_data(iObj) = false;
       if any(obj_idx_lens~= UINT32_MAX)
          %Check that no read values are ever specified
          %i.e. check n_values_per_read
          error('Unhandled case')
          
       end
   end

   %---------------------------------------------
   if final_obj__has_raw_data(iObj)   
       %TODO: Should also set raw data here as well

       mask = obj_data_types == obj_data_types(1) | obj_idx_lens == 0;
       if ~all(mask)
           %TODO: I think this will fail for Lazerus readings
           %- will need to OR mask with UINT32_MAX
           %TODO: Allow providing more information
          error('Mismatch in types'); 
       end
       final_obj__data_type(iObj) = obj_data_types(I_data_type);
   end
end

obj.data_types = final_obj__data_type;
obj.haw_raw_data = final_obj__has_raw_data;

n_bytes_by_type = tdms.meta.getNBytesByTypeArray;

obj.default_byte_size(obj.haw_raw_data) = n_bytes_by_type(obj.data_types(obj.haw_raw_data)); 

end