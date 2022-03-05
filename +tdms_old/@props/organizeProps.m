function organizeProps(obj)
%
%   tdms.props.organizeProps
%
%

%Inputs
%---------------------------------------------
raw_obj           = obj.parent.raw_meta;
final_id_info_obj = obj.parent.final_id_info;
%---------------------------------------------

prop__raw_obj_id = raw_obj.prop__raw_obj_id;
prop__names      = raw_obj.prop__names;
prop__values     = raw_obj.prop__values;

raw_to_final_map = final_id_info_obj.raw_id_to_final_id_map;

%General Algorithm Below
%------------------------------------------
%Column 1 represents a unique channel/object
%Column 2 represents a unique property name
%
%The indices represent the original property/value pairs
%Using sortrows we can grab the unique object/property name pairs. We use
%last to ensure grabbing the last assignment of the property.

[u_prop_names,~,u_prop_id] = unique(prop__names);
u_prop_names__fixed = tdms.meta.fixNames(u_prop_names);

final_ids_by_prop = raw_to_final_map(prop__raw_obj_id);

prop_assignment_matrix = [final_ids_by_prop(:) u_prop_id(:)];

%NOTE: The last is important here as is ensures we get the last value
%that a property takes ...
[u_prop_assignments,index_prop_values_use] = unique(prop_assignment_matrix,'rows','last');
%TODO: If this is not 1:1 in terms of size of unique vs input, then some
%property has been overwritten at a later point in time. Should check and
%maybe save this info somewhere ...

%u_prop_assignments
%Example:
%      1     1
%      1     2
%      1     3
%      1     6
%      1     7
%      2     4
%      3     5
%      4     5
%      5     5


%TODO: We should write the slow method and have the option to check that
%they are the same

prop_name_I  = u_prop_id(index_prop_values_use);
prop_value_I = index_prop_values_use;

I_diff_obj_end   = [find(diff(u_prop_assignments(:,1)) ~= 0); size(u_prop_assignments,1)];
I_diff_obj_start = [1; I_diff_obj_end(1:end-1)+1];

n_objs_with_properties = length(I_diff_obj_end);
obj.n_objs_with_properties = n_objs_with_properties;

obj.final_obj_ids = u_prop_assignments(I_diff_obj_start,1);

temp__prop_names  = cell(1,n_objs_with_properties);
temp__prop_values = cell(1,n_objs_with_properties);

for iObj = 1:n_objs_with_properties
    cur_start_I = I_diff_obj_start(iObj);
    cur_end_I   = I_diff_obj_end(iObj);
    
    temp__prop_names{iObj}  = u_prop_names__fixed(prop_name_I(cur_start_I:cur_end_I));
    temp__prop_values{iObj} = prop__values(prop_value_I(cur_start_I:cur_end_I));
end

obj.prop_names = temp__prop_names;
obj.prop_values = temp__prop_values;