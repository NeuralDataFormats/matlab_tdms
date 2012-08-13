function getProps(obj,fid)
%
%   NAME: tdms.lead_in.getProps
%
%   

%LEAD IN PROCESSING
%================================================
%1) TDSm - (indicats lead in)
Ttag = fread(fid,1,'uint8');
Dtag = fread(fid,1,'uint8');
Stag = fread(fid,1,'uint8');
mtag = fread(fid,1,'uint8');

if ~(Ttag == 84 && Dtag == 68 && Stag == 83 && mtag == obj.last_letter)
    error('Unexpected lead in header')
end

%2) FLAGS
%=============================================
tocMask = fread(fid,1,'*uint32');
obj.has_meta_data   = bitget(tocMask,2);
obj.new_obj_list    = bitget(tocMask,3);
obj.has_raw_data    = bitget(tocMask,4);
obj.is_interleaved  = bitget(tocMask,6);
obj.is_big_endian   = bitget(tocMask,7);
obj.has_raw_daqmx   = bitget(tocMask,8);

if obj.is_big_endian
    error('Code is currently unable to handle Big-Endian format')
end

if obj.has_raw_daqmx
    %JAH TODO: point user to document on this topic ...
    error('Code is unable to ignore/handle Raw Daq MX data')
end

%3) Version Number
%===================================

obj.ver_number  = fread(fid,1,'uint32');
obj.seg_length  = fread(fid,1,'uint64');
obj.meta_length = fread(fid,1,'uint64');

%NOT THROWING THIS ERROR RIGHT NOW
%======================================================================
%This should really quit instead of throwing an error
if obj.seg_length == 2^64-1
    error('File got corrupted when saving')
end

%This most likely suggests an error in the reading
if obj.has_meta_data ~= (obj.meta_length ~= 0)
    error('Flags suggest presence of meta data but no meta is present according to length value')
end


end