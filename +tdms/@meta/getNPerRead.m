function getNPerRead(obj,final_id,n_unique_objs)


n_bytes_by_type = getNBytesByTypeArray(obj);

raw_meta_obj = obj.raw_meta;

chan_set          = zeros(1,n_unique_objs);
data_types_by_obj = zeros(1,n_unique_objs);

n_values_current  = zeros(1,n_unique_objs);
n_bytes_current   = zeros(1,n_unique_objs);

n_values_per_read_final = raw_meta_obj.obj_n_values_per_read;
n_bytes_per_read_final  = raw_meta_obj.obj_n_bytes_per_read;
obj_len    = raw_meta_obj.obj_len;
data_types = raw_meta_obj.obj_data_types;

%TODO: Ensure that MAX_INT occurs for new object list
%NOTE: If it doesn't that isn't necessarily bad, I just need to write 
%code that makes sure it is handled right ...

%NOTE: I could potentially do this faster on a per object basis but the
%code might be a bit messier ...
for iRaw = find(raw_meta_obj.obj_has_raw_data)
    cur_chan_id = final_id(iRaw);
    if obj_len(iRaw) == 0
        if chan_set(cur_chan_id)
            n_values_per_read_final(iRaw) = n_values_current(cur_chan_id);
            n_bytes_per_read_final(iRaw)  = n_bytes_current(cur_chan_id);
        else
            %TODO: Provide reference to some error code, improve msg
            error('Channel data info has yet to be set')
        end
    else
        n_values_current(cur_chan_id) = n_values_per_read_final(iRaw);
        n_bytes_current(cur_chan_id)  = n_bytes_per_read_final(iRaw);
        if chan_set(cur_chan_id) && data_types_by_obj(cur_chan_id) ~= data_types(iRaw)
            %TODO: Provide reference to some error code, improve msg
            error('Data type can''t change ...')
        else
            chan_set(cur_chan_id) = true;
            data_types_by_obj(cur_chan_id) = data_types(iRaw);
        end
    end
end

%Update bytes per read for non-string types
mask = n_bytes_per_read_final == 0 & n_values_per_read_final ~= 0;
n_bytes_per_read_final(mask) = n_bytes_by_type(data_types(mask)).*n_values_per_read_final(mask);

obj.n_bytes_per_read  = n_bytes_per_read_final; 
obj.n_values_per_read = n_values_per_read_final;


%Not sure if this is needed
%data_types_read_final        = data_types_by_obj(final_id);

end

%SOME OLD CODE
%==========================================
% data_types = raw_meta_obj.data_types;
% obj_len = raw_meta_obj.obj_len;
%
% data_type_all_objs = zeros(1,n_unique_objs);
% for iObj = 1:n_unique_objs
%    local_indices    = u_obj_names__indices{iObj};
%    local_data_types = data_types(local_indices);
%
%    I_non_zero = find(local_data_types ~= 0,1);
%
%    if isempty(I_non_zero)
%        %Assume raw data only,
%        if ~all(obj_len(local_indices)) == MAX_INT
%            error('No data type specified for object')
%        end
%    else
%       %NOTE: Are non-zero values all the same
%       obj_data_type = local_data_types(I_non_zero);
%       %NOTE: Might need to handle MAX_INT as well
%       if any(local_data_types ~= obj_data_type || local_data_types ~= 0)
%           error('Data type change is not supported')
%       end
%
%       %NOTE: If MAX_INT changes here, change this code as well
%       %i.e. if MAX_INT creeps in, then we can't set all data types
%       %to be what they are below ...
%       data_types(local_indices(I_non_zero:end)) = obj_data_type;
%       data_type_all_objs(iObj) = obj_data_type;
%    end
% end

