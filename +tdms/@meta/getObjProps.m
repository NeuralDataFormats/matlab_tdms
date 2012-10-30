function getObjProps(obj,orig_obj_final_id,n_unique_objs)

%
%   TODO: Rename function 
%



%GENERAL ALGORITHM BELOW
%================================================
%Column 1 represents a unique object
%Column 2 represents a unique property name
%The indices represent the original property/value pairs
%Using sortrows we can grab the unique object/property name pairs. We use
%last to ensure grabbing the last assignment of the property.


prop_chan_ids = obj.raw_meta.prop__raw_obj_id;
prop_names    = obj.raw_meta.prop_names;
prop_values   = obj.raw_meta.prop_values;

nProps = length(prop_chan_ids);

prop_assignment_matrix = zeros(nProps,2);
prop_assignment_matrix(:,1) = orig_obj_final_id(prop_chan_ids);
%row index = property
%column 1 value = final obj id
%colum 2 value  = unique prop id

[u_prop_names,~,prop_assignment_matrix(:,2)] = unique(prop_names(1:nProps));
%TODO: Fix names


[u_prop_assignments,index_prop_values_use] = unique(prop_assignment_matrix,'rows','last');
%TODO: If this is not 1:1 in terms of size of unique vs input, then some
%property has been overwritten at a later point in time. Should check and
%maybe save this info somewhere ...


I_diff_obj_end   = [find(diff(u_prop_assignments(:,1)) ~= 0); size(u_prop_assignments,1)];
I_diff_obj_start = [1; I_diff_obj_end(1:end-1)+1];

obj_props = struct('names',repmat({{}},1,n_unique_objs),'values',{{}});

n_objs_with_props = length(I_diff_obj_end);
for iUniqueObj = 1:n_objs_with_props
   unique_indices_for_obj = I_diff_obj_start(iUniqueObj):I_diff_obj_end(iUniqueObj);
   prop_indices = index_prop_values_use(unique_indices_for_obj);
   n_props_for_obj = length(prop_indices);
   prop_names_obj  = cell(1,n_props_for_obj);
   prop_values_obj = cell(1,n_props_for_obj);
   for iProp = 1:n_props_for_obj
      %NOTE: This is incorrect, need to translate back to unicode
      prop_names_obj(iProp)  = prop_names(prop_indices(iProp));  
      prop_values_obj(iProp) = prop_values(prop_indices(iProp));
   end
   obj_index = u_prop_assignments(iUniqueObj,1);
   obj_props(obj_index).names  = prop_names_obj;
   obj_props(obj_index).values = prop_values_obj;
end

obj.props = obj_props;