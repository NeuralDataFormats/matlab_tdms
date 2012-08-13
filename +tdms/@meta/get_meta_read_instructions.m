function [fread_prop_info,nBytesByType] = get_meta_read_instructions(obj)

fread_prop_info       = cell(1,68);
fread_prop_info(1:10) = {@readInt8 @readInt16 @readInt32 @readInt64 @readUint8 @readUint16 @readUint32 @readUint64 @readSingle @readDouble};
fread_prop_info{25}   = @readSingle;
fread_prop_info{26}   = @readDouble;
fread_prop_info{32}   = @readString;
fread_prop_info{33}   = @readLogical;
fread_prop_info{68}   = @readTimestamp;

nBytesByType        = zeros(1,68);
nBytesByType(1:10)  = [1:4 1:4 4 8];
nBytesByType(25)    = 4;
nBytesByType(26)    = 8;
nBytesByType(33)    = 1;
nBytesByType(68)    = 16;

end

function out = readInt8(fid)
   out = fread(fid,1,'*int8');
end

function out = readInt16(fid)
   out = fread(fid,1,'*int16');
end

function out = readInt32(fid)
   out = fread(fid,1,'*int32');
end

function out = readInt64(fid)
   out = fread(fid,1,'*int64');
end

function out = readUint8(fid)
   out = fread(fid,1,'*uint8');
end

function out = readUint16(fid)
   out = fread(fid,1,'*uint16');
end

function out = readUint32(fid)
   out = fread(fid,1,'*uint32');
end

function out = readUint64(fid)
   out = fread(fid,1,'*uint64');
end

function out = readSingle(fid)
   out = fread(fid,1,'*single');
end

function out = readDouble(fid)
   out = fread(fid,1,'*double');
end

function out = readString(fid)
   out = fread(fid,fread(fid,1,'uint32'),'uint8=>char')';
end

function out = readLogical(fid)
   out = logical(fread(fid,1,'*uint8'));
end

function out = readTimestamp(fid)
% % % firstByte  = fread(fid,1,'uint64');
% % % secondByte = fread(fid,1,'int64');
% % % tSeconds     = firstByte/(2^64)+secondByte;
% % % propValue    = datestr(tSeconds/SECONDS_IN_DAY + CONV_FACTOR + UTC_DIFF/24,DATE_STR_FORMAT);

   uint64_max = 2^64;
   out = fread(fid,1,'uint64')/uint64_max + fread(fid,1,'int64');
end