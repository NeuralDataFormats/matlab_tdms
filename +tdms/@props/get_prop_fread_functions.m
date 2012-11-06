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


function [out,cur_index] = readInt8(str,cur_index)
out = typecast(str(cur_index+1),'int8');
cur_index = cur_index + 1;
end

function [out,cur_index] = readInt16(str,cur_index)
out = typecast(str((cur_index+1):(cur_index+2)),'int16');
cur_index = cur_index + 2;
end

function [out,cur_index] = readInt32(str,cur_index)
out = typecast(str((cur_index+1):(cur_index+4)),'int32');
cur_index = cur_index + 4;
end

function [out,cur_index] = readInt64(str,cur_index)
out = typecast(str((cur_index+1):(cur_index+8)),'int64');
cur_index = cur_index + 8;
end

function [out,cur_index] = readUint8(str,cur_index)
out = str(cur_index+1);
cur_index = cur_index + 1;
end

function [out,cur_index] = readUint16(str,cur_index)
out = typecast(str((cur_index+1):(cur_index+2)),'uint16');
cur_index = cur_index + 2;
end

function [out,cur_index] = readUint32(str,cur_index)
out = typecast(str((cur_index+1):(cur_index+4)),'uint32');
cur_index = cur_index + 4;
end

function [out,cur_index] = readUint64(str,cur_index)
out = typecast(str((cur_index+1):(cur_index+8)),'uint64');
cur_index = cur_index + 8;
end

function [out,cur_index] = readSingle(str,cur_index)
out = typecast(str((cur_index+1):(cur_index+4)),'single');
cur_index = cur_index + 4;
end

function [out,cur_index] = readDouble(str,cur_index)
out = typecast(str((cur_index+1):(cur_index+8)),'double');
cur_index = cur_index + 8;
end

function [out,cur_index] = readString(str,cur_index)
% flag = false;
% out = fread(fid,fread(fid,1,'uint32'),'uint8=>char')';

STR_ENCODING = 'UTF-8';
[n_bytes,cur_index] = readUint32(str,cur_index);
out = native2unicode(str(cur_index+1:cur_index+n_bytes),STR_ENCODING);
cur_index = cur_index + n_bytes;

end

function [out,cur_index] = readLogical(str,cur_index)
out = logical(str(cur_index+1));
cur_index = cur_index + 1;
end

function [out,cur_index] = readTimestamp(str,cur_index)
% % % firstByte  = fread(fid,1,'uint64');
% % % secondByte = fread(fid,1,'int64');
% % % tSeconds     = firstByte/(2^64)+secondByte;
% % % propValue    = datestr(tSeconds/SECONDS_IN_DAY + CONV_FACTOR + UTC_DIFF/24,DATE_STR_FORMAT);

uint64_max = 2^64;
%out = fread(fid,1,'uint64')/uint64_max + fread(fid,1,'int64');
out = double(readUint64(str,cur_index))/uint64_max + double(readInt64(str,cur_index+8));
cur_index = cur_index + 16;
end