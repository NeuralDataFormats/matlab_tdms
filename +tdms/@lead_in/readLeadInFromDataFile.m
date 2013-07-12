function readLeadInFromDataFile(obj)
%
%
%
%   IMPROVEMENTS
%   =======================================================================
%   1) At some point I had considered allowing reading of the entire
%
%

GROWTH_SIZE = obj.options_obj.lead_in_GROWTH_SIZE;


first_word = obj.first_word;

fid = obj.fid;

INIT_SIZE    = obj.options_obj.lead_in_INIT_SIZE;
lead_in_data = zeros(7,INIT_SIZE,'uint32');
meta_data    = cell(1,INIT_SIZE);
n_segs       = 0;

fseek(fid,0,1);
eof_position = ftell(fid);
fseek(fid,0,-1);

invalid_segment_found = false;
keep_reading = true;
while keep_reading
    n_segs = n_segs + 1;
    
    if n_segs > size(lead_in_data,2)
       if nsegs > size(lead_in_data,2)
           lead_in_data = [lead_in_data zeros(7,GROWTH_SIZE,'uint32')]; %#ok<AGROW>
           meta_data    = [meta_data cell(1,GROWTH_SIZE)]; %#ok<AGROW>
       end 
    end
    temp = fread(fid,7,'*uint32');
    if temp(1) ~= first_word
        invalid_segment_found = true;
        keep_reading = false;
    else
        %Grab meta data
        %advance index
        %hold onto lead in data
        
        lead_in_data(:,n_segs) = temp;
        
        seg_length  = typecast(temp(4:5),'uint64');
        meta_length = typecast(temp(6:7),'uint64');
        
        meta_data{n_segs} = fread(fid,meta_length,'*uint8');
        fseek(fid,double(seg_length-meta_length),0); %The double() kills me
        
        keep_reading = ftell(fid) < eof_position;
        
        %
    end
end

%TODO: Truncate sizes ...



keyboard