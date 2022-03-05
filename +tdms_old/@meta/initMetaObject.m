function initMetaObject(obj)
%initMetaObject Initializes tdms.meta object
%
%   tdms.meta.initMetaObject
%
%   See Also:
%   tdms.meta.raw

%Step 1: Extract info from meta data
%----------------------------------------------
obj.raw_meta = tdms.meta.raw(obj);

%Step 2: Get information regarding each final object
%----------------------------------------------------
obj.final_id_info = tdms.meta.final_id_info(obj);

%Step 3: Generate corrected unique segment info
%----------------------------------------------
obj.corrected_seg_info = tdms.meta.corrected_segment_info.initializeObjects(obj);



obj.final_segment_info = tdms.meta.final_segment_info.initializeObjects(obj);

obj.props      = tdms.props(obj);

%obj.read_info  = tdms.data.read_info(obj);

end
