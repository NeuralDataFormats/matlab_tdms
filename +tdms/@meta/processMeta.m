function processMeta(obj)
%processMeta
%
%   NAME: tdms.meta.processMeta


%Step 1: Extract info from meta data
%----------------------------------------------
obj.raw_meta   = tdms.meta.raw(obj);

return

%Step 2: Consolidate objects into final set
%----------------------------------------------
obj.final_ids  = tdms.meta.final_id(obj);

%Step 3: Expand read instructions
%----------------------------------------------
obj.fixed_meta = tdms.meta.fixed(obj);

obj.props      = tdms.props(obj); 

obj.read_info  = tdms.data.read_info(obj);

end