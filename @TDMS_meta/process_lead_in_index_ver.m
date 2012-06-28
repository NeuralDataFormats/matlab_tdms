function info = process_lead_in_index_ver(obj,data,curIndex)
%
%
%
% Compare to processLeadIn

%Maybe just pass this in, instead ...
fid = obj.fid;

%fseek(fid,0,-1)

tic
TDS_tag = typecast(data(curIndex:curIndex+3),'uint32');

curIndex = curIndex + 4;
toc
%TDS_tag = fread(fid,1,'*uint32');

%typecast(uint8('TDSh'),'uint32') - done ahead for speed
if TDS_tag ~= 1750287444
   %For the index, the tag should be 'TDSh' 
   %char(typecast(TDS_tag,'uint8'))
   error('Unexpected lead in header, error in code or file')
end

%table of contents mask????
%Which

toc_mask = typecast(data(curIndex),'uint8');

cur_seg__has_meta_data  = bitget(toc_mask,2);
cur_seg__new_obj_list   = bitget(toc_mask,3);
cur_seg__has_raw_data   = bitget(toc_mask,4);
cur_seg__is_interleaved = bitget(toc_mask,6);
cur_seg__is_big_endian  = bitget(toc_mask,7);
cur_seg__has_raw_daq_mx = bitget(toc_mask,8);

curIndex = curIndex + 4;



% toc_mask = logical(fread(fid,32,'*ubit1'));  
% 
% %NOTE: I really don't need to hold onto this crap
% %if I know where the start is located, I am good, just give me the struct
% %...
% 
% s = obj.seg_info;
% cur_seg_index = obj.cur_seg_index;
% s.has_meta_data(cur_seg_index)    = toc_mask(2);
% s.has_new_obj_list(cur_seg_index) = toc_mask(3);
% s.haw_raw_data(cur_seg_index)     = toc_mask(4);
% s.is_interleaved(cur_seg_index)   = toc_mask(6);
% s.is_big_endian(cur_seg_index)    = toc_mask(7);
% 
% haw_raw_daqmx = toc_mask(8);


if flags.isBigEndian(cur_seg_index)
   error('Currently code is unable to handle Big-Endian format')
end

if flags.hasRawDaqMX
   error('Currently code is unable to ignore/handle Raw Daq MX data') 
end

%ignore ver number
%'verNumber',  fread(fid,1,'*uint32'),...  %This is not very well defined
curIndex = curIndex + 4;

seg_length = typecast(data(curIndex:curIndex+7),'uint64');
curIndex = curIndex + 8;

meta_length = typecast(data(curIndex:curIndex+7),'uint64');
        %3) Version Number
        info = struct(...
            
            ... %NOTE: It is not v1 or v2, it is an internal versioning of the files ...
            'segLength',  fread(fid,1,'*uint64'),...
            'metaLength', fread(fid,1,'*uint64'));  

        if info.segLength == 2^64-1
            s.last_segment_partial = true;
        end
        
        if ~eof_error && s.has_meta_data(cur_seg_index) ~= (info.metaLength ~= 0)
            error('Flags suggest presence of meta data but no meta is present according to length value')
        end
        
keyboard
