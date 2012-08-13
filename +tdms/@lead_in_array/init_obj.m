function init_obj(obj,fid,reading_index_file)

INIT_SIZE   = 1000;
GROWTH_SIZE = 1000;

LEAD_IN_BYTE_LENGTH = obj.LEAD_IN_BYTE_LENGTH;

%NOTE: This could be mexed ...

%IMPROVEMENTS:
%===============================
%NOTE: Instead of data_start, we could just keep track of data length ...

if reading_index_file
   first_word = typecast(uint8('TDSh'),'uint32');  
else
   first_word = typecast(uint8('TDSm'),'uint32'); 
end

n_segs   = 0; %#ok<*PROP>

toc_mask   = zeros(1,INIT_SIZE,'uint32');
meta_start = zeros(1,INIT_SIZE); %Index or file related
data_start = zeros(1,INIT_SIZE); %File related only

cur_data_position = 0;

fseek(fid,0,1);
eofPosition = ftell(fid);
fseek(fid,0,-1);

while ftell(fid) ~= eofPosition
    n_segs = n_segs + 1;
    if n_segs > length(toc_mask)
        %grow stuff
        toc_mask   = [toc_mask   zeros(1,GROWTH_SIZE,'uint32')]; %#ok<AGROW>
        meta_start = [meta_start zeros(1,GROWTH_SIZE)]; %#ok<AGROW>
        data_start = [data_start zeros(1,GROWTH_SIZE)]; %#ok<AGROW>
    end
    
    [lead_in_array,lengths]    = readLeadIn(obj,fid,first_word);
    
    toc_mask(n_segs)   = lead_in_array(2);
    cur_data_position  = cur_data_position + LEAD_IN_BYTE_LENGTH;
    
    meta_start(n_segs) = ftell(fid); %Don't use cur_data_position
    %Could be reading from the index
    
    %NOTE: We're going to ignore version number for now ...

    %NOTE: Lengths ignore the lead_in
    seg_length      = lengths(1);
    meta_length     = lengths(2); 
    
    %NOTE: For rawDAQmx, this might be problematic :/
    
    if reading_index_file
        fseek(fid,meta_length,0);
    else
        fseek(fid,seg_length,0);
    end
    
    data_start(n_segs) = cur_data_position + meta_length;
    cur_data_position  = cur_data_position + seg_length;
end

obj.n_segs = n_segs;
obj.data_start = data_start;
obj.meta_start = meta_start;
obj.toc_mask = toc_mask;


end