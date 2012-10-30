function extractMetaInfo(obj)

fread_prop_info = tdms.props.get_prop_fread_functions2;

MAX_INT        = 2^32-1;
INIT_OBJ_SIZE  = 10000;
INIT_PROP_SIZE = 1000;

%OBJECT PROPERTIES
%=================================================
raw_obj_names = cell(1,INIT_OBJ_SIZE);  %all object names, NOT UNICODE
obj_seg      = zeros(1,INIT_OBJ_SIZE); %segment in which the object appeared
obj_len      = zeros(1,INIT_OBJ_SIZE); %all obj index lengths, 0, MAXINT, 20, or 28
obj_idx_data = zeros(6,INIT_OBJ_SIZE,'uint32'); %The contents of the idx data
%NOTE: not all of this is uint32, some uint64 exist as well
%We expect at most to have 28 bytes, of which 4 we will ignore as those go
%into obj_len, 24 bytes with uint32 is 6 values

cur_obj_index = 0;                     

%PROPERTY HANDLING
%===============================================
prop_names      = cell(1,INIT_PROP_SIZE);
prop_values     = cell(1,INIT_PROP_SIZE);
prop__raw_obj_id   = zeros(1,INIT_PROP_SIZE);
prop_types      = zeros(1,INIT_PROP_SIZE);
cur_prop_index  = 0;

meta_data = obj.lead_in.meta_data;

for iSeg = 1:obj.lead_in.n_segs
    cur_u8_data  = meta_data{iSeg};
    cur_u32_data = get_uint32_data(cur_u8_data);
    
    n_objects = cur_u32_data(1,1);
    
    %TODO: Handle object overflow ...
    
    cur_index = 4;
    obj_seg(cur_obj_index+1:cur_obj_index+n_objects) = iSeg;
    for iObject = 1:n_objects
        cur_obj_index = cur_obj_index + 1;
        
        %NAME RETRIEVAL ---------------------------------------------------
        object_name_byte_length = cur_u32_data(cur_index+1);
        cur_index = cur_index + 4;
        %NOTE: Name is incorrect, but we'll fix it later
        raw_obj_names{cur_obj_index} = char(cur_u8_data((cur_index+1):(cur_index+object_name_byte_length)));
        cur_index = cur_index + object_name_byte_length;
        
        %INDEX LENGTH HANDLING --------------------------------------------
        index_length = cur_u32_data(cur_index+1);
        cur_index    = cur_index + 4;
        obj_len(cur_obj_index) = index_length;
        
        if index_length == MAX_INT || index_length == 0
            %do nothing
        elseif index_length == 20 %Grab 4 values
            obj_idx_data(1:4,cur_obj_index) = cur_u32_data(cur_index+1:4:cur_index+13);
            cur_index = cur_index + 16;
        elseif index_length == 28 %Grab 6 values
            obj_idx_data(:,cur_obj_index)   = cur_u32_data(cur_index+1:4:cur_index+23);
            cur_index = cur_index + 24;
        else
            error('Unexpected index length')
        end
        
        %PROPERTY HANDLING
        %==================================================================
        n_properties = cur_u32_data(cur_index+1);
        cur_index    = cur_index + 4;
        
        %TODO: Handle property overflow
        
        prop__raw_obj_id(cur_prop_index+1:cur_prop_index+n_properties) = cur_obj_index;
        for iProp = 1:n_properties
            cur_prop_index = cur_prop_index + 1;
            
            %NAME RETRIEVAL -----------------------------------------------
            prop_name_byte_length = cur_u32_data(cur_index+1);
            cur_index = cur_index + 4;
            
            %NOTE: Could do non-unicode to unicode trick here as well
            prop_names{cur_prop_index} = char(cur_u8_data((cur_index+1):(cur_index+prop_name_byte_length)));
            cur_index = cur_index +  prop_name_byte_length;
            
            %TYPE RETRIEVAL -----------------------------------------------
            prop_types(cur_prop_index) = cur_u32_data(cur_index+1);
            cur_index = cur_index + 4;
            
            %VALUE RETRIEVAL ----------------------------------------------
            [prop_values{cur_prop_index},cur_index] = feval(fread_prop_info{prop_types(cur_prop_index)},cur_u8_data,cur_index);
        end
    end
    %TODO: Add raw data vs new object check ...
    %i.e. check raw data flag, add in code that looks for objects with new 
    %data
end

raw_meta_obj = tdms.raw_meta;

raw_meta_obj.obj_names = raw_obj_names(1:cur_obj_index);
raw_meta_obj.obj_seg   = obj_seg(1:cur_obj_index);
raw_meta_obj.obj_len   = obj_len(1:cur_obj_index);
raw_meta_obj.obj_has_raw_data = raw_meta_obj.obj_len ~= MAX_INT;


raw_meta_obj.obj_data_types    = obj_idx_data(1,1:cur_obj_index);
%NOTE: Ignoring dimension - row 2, for now
raw_meta_obj.obj_n_values_per_read    = double(typecastC(obj_idx_data(3:4,1:cur_obj_index),'uint64'))';
raw_meta_obj.obj_n_bytes_per_read     = double(typecastC(obj_idx_data(5:6,1:cur_obj_index),'uint64'))';

raw_meta_obj.prop_names  = prop_names(1:cur_prop_index);
raw_meta_obj.prop_values = prop_values(1:cur_prop_index);
raw_meta_obj.prop__raw_obj_id = prop__raw_obj_id(1:cur_prop_index);
raw_meta_obj.prop_types = prop_types(1:cur_prop_index);

obj.raw_meta = raw_meta_obj;

end

function cur_uint32_seg_data = get_uint32_data(cur_seg_meta_data)
n_1 = floor(0.25*length(cur_seg_meta_data));
n_2 = floor(0.25*(length(cur_seg_meta_data)-1));
n_3 = floor(0.25*(length(cur_seg_meta_data)-2));
n_4 = floor(0.25*(length(cur_seg_meta_data)-3));

cur_uint32_seg_data = zeros(4,n_1);   %Or do I make this double?

cur_uint32_seg_data(1,1:n_1) = double(typecast(cur_seg_meta_data(1:4*n_1),'uint32'));
cur_uint32_seg_data(2,1:n_2) = double(typecast(cur_seg_meta_data(2:(4*n_2+1)),'uint32'));
cur_uint32_seg_data(3,1:n_3) = double(typecast(cur_seg_meta_data(3:(4*n_3+2)),'uint32'));
cur_uint32_seg_data(4,1:n_4) = double(typecast(cur_seg_meta_data(4:(4*n_4+3)),'uint32'));
%NOTE: By going down rows for different shifts, indices
%will direcetly index into m
end