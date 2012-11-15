function readMeta(obj)
%readMeta
%
%   NAME: tdms.meta.readMeta

obj.lead_in    = tdms.lead_in(obj);

obj.raw_meta   = tdms.meta.raw(obj);

obj.final_ids  = tdms.meta.final_id(obj);

obj.fixed_meta = tdms.meta.fixed(obj);

obj.props      = tdms.props(obj); 

obj.read_info  = tdms.data.read_info(obj);

end