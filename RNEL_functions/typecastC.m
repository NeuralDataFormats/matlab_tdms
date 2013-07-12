function output = typecastC(data,format,keepShape)
%typecastC  Typecast columns of data
%
%   output = typecastC(data,format,*keepShape)
%
%   At its simplest level this function avoids multiple lines
%   of code for first assigning a temporary variable and then linearizing
%   it because typecasting only works on a vector.
%
%   In addition you can optionally ensure that the # of columns doesn't
%   change in this call. This is useful if multiple rows exist going into
%   the call.
%
%   INPUTS
%   =======================================================
%   data      : data to typecast, ROWS form bytes to group together
%   format    : 
%   keepShape : (default false), if true # of columns doesn't change 
%               between input and output
%   
%   EXAMPLES
%   ========================================================
%   x = uint8(rand(2,10));
%   y = typecastC(x,'uint16'); %Will form 10 samples of uint16, joining rows
%   NOTE: This seemingly simple call fails when using typecast due to error checking
%
%   x = uint8(rand(4,10));
%   y = typecastC(x,'uint16',true); %output will be 2 x 10 instead of 1 x 20

    nOrig  = size(data,2);
    output = typecast(data(:),format);
    if exist('keepShape','var') && keepShape && length(output) ~= nOrig
       output = reshape(output,[length(output)/nOrig nOrig]); 
    end
end