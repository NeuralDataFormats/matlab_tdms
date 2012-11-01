function getNPerRead(obj,final_obj_id,n_unique_objs)
%
%
%   getNPerRead(obj,final_obj_id,n_unique_objs)
%
%
%   NOTE: Importantly, a value of raw_obj__idx_len equals zero specifies
%   that the object should use the previous index data in which it had
%   data.
%
%   TODO: Finish documentation


%For Reference
%------------------------------------------------------------------
n_bytes_by_type     = getNBytesByTypeArray(obj);
raw_meta_obj        = obj.raw_meta;
raw_obj__idx_len    = raw_meta_obj.raw_obj__idx_len;
raw_obj__data_types = raw_meta_obj.raw_obj__data_types;

%Intermediate variables to assist processing 
%------------------------------------------------------------------
final_obj__set          = zeros(1,n_unique_objs);
final_obj__data_type    = zeros(1,n_unique_objs);
final_obj__cur_n_values = zeros(1,n_unique_objs);
final_obj__cur_n_bytes  = zeros(1,n_unique_objs);

%These are the output variables. We start with what they were previously.
%We then update them as we come across instructions that tell us to use the
%previous value.
n_values_per_read_final = raw_meta_obj.raw_obj__n_values_per_read;
n_bytes_per_read_final  = raw_meta_obj.raw_obj__n_bytes_per_read;

%NOTE: The length is not often zero. I could write a separte case which
%only does the previous value checking ...
for iRaw = find(raw_meta_obj.raw_obj__has_raw_data)
    cur_final_id = final_obj_id(iRaw);
    if raw_obj__idx_len(iRaw) == 0
        if final_obj__set(cur_final_id)
            n_values_per_read_final(iRaw) = final_obj__cur_n_values(cur_final_id);
            n_bytes_per_read_final(iRaw)  = final_obj__cur_n_bytes(cur_final_id);
        else
            %TODO: Provide reference to some error code, improve msg
            error('Channel data info has yet to be set')
        end
    else
        final_obj__cur_n_values(cur_final_id) = n_values_per_read_final(iRaw);
        final_obj__cur_n_bytes(cur_final_id)  = n_bytes_per_read_final(iRaw);
        if final_obj__set(cur_final_id) && final_obj__data_type(cur_final_id) ~= raw_obj__data_types(iRaw)
            %TODO: Provide reference to some error code, improve msg
            error('Data type can''t change ...')
        else
            final_obj__set(cur_final_id) = true;
            final_obj__data_type(cur_final_id) = raw_obj__data_types(iRaw);
        end
    end
end

%Update bytes per read for non-string types
%--------------------------------------------------------
data_types_final = final_obj__data_type(final_obj_id);
mask = n_bytes_per_read_final == 0 & n_values_per_read_final ~= 0;
n_bytes_per_read_final(mask) = n_bytes_by_type(data_types_final(mask)).*n_values_per_read_final(mask);

%Final assignment
%--------------------------------------------------------
obj.n_bytes_per_read  = n_bytes_per_read_final; 
obj.n_values_per_read = n_values_per_read_final;


end