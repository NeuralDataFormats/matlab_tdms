function [data_type,array_dim,n_vals_per_read,n_bytes] = getRawDataSpecs(obj,fid)

%NO LONGER USED

data_type       = fread(fid,1,'uint32');
array_dim       = fread(fid,1,'uint32');
n_vals_per_read = fread(fid,1,'uint64');
if data_type == 32
    n_bytes = fread(fid,1,'uint64');
else
    n_bytes = 1;
end           

end