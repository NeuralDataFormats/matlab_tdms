function initMetaObject(obj)
%initMetaObject Initializes tdms.meta object
%
%   tdms.meta.initMetaObject
%
%   See Also:
%   tdms.meta.raw

%Possible Optimization:
%----------------------
%If there is a new list and the same sets of meta segments afterwards
%before a new list, as has been seen previously, we could replicate the
%final results from the previous translation.
%e.g.
%If we have the segments:
%a b c a b c a
%
%Where a b & c represent segments with instructions and 'a' starts a new
%object list, then once we translate the first 3 segments, we could
%duplicate these instructions (nearly) for generating the second set of
%segments. The only thing that would change is the data starts.


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
