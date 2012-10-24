function fread_prop_info = get_prop_fread_functions()
%
%
%   Static Method

fread_prop_info       = cell(1,68);
fread_prop_info(1:10) = {@readInt8 @readInt16 @readInt32 @readInt64 @readUint8 @readUint16 @readUint32 @readUint64 @readSingle @readDouble};
fread_prop_info{25}   = @readSingle;
fread_prop_info{26}   = @readDouble;
fread_prop_info{32}   = @readString;
fread_prop_info{33}   = @readLogical;
fread_prop_info{68}   = @readTimestamp;
end


function [out,flag] = readInt8(fid)
flag = false;
out = fread(fid,1,'*int8');
end

function [out,flag] = readInt16(fid)
flag = false;
out = fread(fid,1,'*int16');
end

function [out,flag] = readInt32(fid)
flag = false;
out = fread(fid,1,'*int32');
end

function [out,flag] = readInt64(fid)
flag = false;
out = fread(fid,1,'*int64');
end

function [out,flag] = readUint8(fid)
flag = false;
out = fread(fid,1,'*uint8');
end

function [out,flag] = readUint16(fid)
flag = false;
out = fread(fid,1,'*uint16');
end

function [out,flag] = readUint32(fid)
flag = false;
out = fread(fid,1,'*uint32');
end

function [out,flag] = readUint64(fid)
flag = false;
out = fread(fid,1,'*uint64');
end

function [out,flag] = readSingle(fid)
flag = false;
out = fread(fid,1,'*single');
end

function [out,flag] = readDouble(fid)
flag = false;
out = fread(fid,1,'*double');
end

function [out,flag] = readString(fid)
flag = false;
out = fread(fid,fread(fid,1,'uint32'),'uint8=>char')';
end

function [out,flag] = readLogical(fid)
flag = false;
out = logical(fread(fid,1,'*uint8'));
end

function [out,flag] = readTimestamp(fid)
flag = true;
% % % firstByte  = fread(fid,1,'uint64');
% % % secondByte = fread(fid,1,'int64');
% % % tSeconds     = firstByte/(2^64)+secondByte;
% % % propValue    = datestr(tSeconds/SECONDS_IN_DAY + CONV_FACTOR + UTC_DIFF/24,DATE_STR_FORMAT);

uint64_max = 2^64;
out = fread(fid,1,'uint64')/uint64_max + fread(fid,1,'int64');
end