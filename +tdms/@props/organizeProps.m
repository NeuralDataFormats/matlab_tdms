function organizeProps(obj)
%
%

%INPUTS NEEDED
%===============================================

raw_obj       = obj.parent.raw_meta;
final_ids_obj = obj.parent.final_ids;

%From raw object:
%----------------------------
%prop__raw_obj_id
%prop__names
%prop__values
%prop__types
%n_props

prop__raw_obj_id = raw_obj.prop__raw_obj_id;
prop__names      = raw_obj.prop__names;
prop__values     = raw_obj.prop__values;
n_props          = raw_obj.n_props;

final_obj_id     = final_ids_obj.final_obj_id;
n_unique_objs    = final_ids_obj.n_unique_objs;

%GENERAL ALGORITHM BELOW
%================================================
%Column 1 represents a unique object
%Column 2 represents a unique property name
%The indices represent the original property/value pairs
%Using sortrows we can grab the unique object/property name pairs. We use
%last to ensure grabbing the last assignment of the property.

[u_prop_names,~,u_prop_id] = unique(prop__names);
u_prop_names__fixed = tdms.meta.fixNames(u_prop_names);

%TODO: Fix names

prop_assignment_matrix = [final_obj_id(prop__raw_obj_id)' u_prop_id'];

%NOTE: The last is important here as is 
[u_prop_assignments,index_prop_values_use] = unique(prop_assignment_matrix,'rows','last');
%TODO: If this is not 1:1 in terms of size of unique vs input, then some
%property has been overwritten at a later point in time. Should check and
%maybe save this info somewhere ...


I_diff_obj_end   = [find(diff(u_prop_assignments(:,1)) ~= 0); size(u_prop_assignments,1)];
I_diff_obj_start = [1; I_diff_obj_end(1:end-1)+1];

obj_props = struct('names',repmat({{}},1,n_unique_objs),'values',{{}});

objs_with_props_indices = u_prop_assignments(I_diff_obj_start,1);
n_objs_with_props = length(I_diff_obj_end);
for iUniqueObj = 1:n_objs_with_props
   unique_props_I = I_diff_obj_start(iUniqueObj):I_diff_obj_end(iUniqueObj);
   
   %These are indices into the original full prop array
   prop_indices      = index_prop_values_use(unique_props_I);
   prop_name_indices = u_prop_id(prop_indices);
   
   obj_index = objs_with_props_indices(iUniqueObj);
   obj_props(obj_index).names  = u_prop_names__fixed(prop_name_indices);
   obj_props(obj_index).values = prop__values(prop_indices);
end

obj.names_value_struct_array = obj_props;