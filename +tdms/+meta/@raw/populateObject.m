function populateObject(obj)
%
%   At this point we loop through the meta data extracting all of the
%   information that is contained in it. We will need to process it further
%   after this but the use of the raw meta data from the initial read will
%   no longer be needed. After this everything is in specific variables as
%   specified in the raw_meta object.

%MLINT
%======================================
%#ok<*AGROW>  %Autogrow ok

fread_prop_info = tdms.props.get_prop_fread_functions2;

MAX_INT        = 2^32-1;
INIT_OBJ_SIZE  = obj.options_obj.raw__INIT_OBJ_SIZE;
INIT_PROP_SIZE = obj.options_obj.raw__INIT_PROP_SIZE;

%OBJECT PROPERTIES
%=================================================
raw_obj__names    = cell(1,INIT_OBJ_SIZE);  %all object names, NOT UNICODE
raw_obj__seg_id   = zeros(1,INIT_OBJ_SIZE); %segment in which the object appeared
raw_obj__idx_len  = zeros(1,INIT_OBJ_SIZE); %all obj index lengths, 0, MAXINT, 20, or 28
raw_obj__idx_data = zeros(6,INIT_OBJ_SIZE,'uint32'); %The contents of the idx data
%NOTE: not all of this is uint32, some are uint64 
%We expect at most to have 28 bytes, of which 4 we will ignore as those go
%into obj_len, this leaves 24 bytes, which with uint32 is 6 values
cur_obj_index = 0;                     

%PROPERTY HANDLING
%===============================================
prop__names      = cell(1,INIT_PROP_SIZE);
prop__values     = cell(1,INIT_PROP_SIZE);
prop__raw_obj_id = zeros(1,INIT_PROP_SIZE);
prop__types      = zeros(1,INIT_PROP_SIZE);
cur_prop_index  = 0;

meta_data = obj.lead_in.meta_data;

%NOTE: It is possible for meta_data to be empty
for iSeg = find(~cellfun('isempty',meta_data))
    cur_u8_data  = meta_data{iSeg};
    cur_u32_data = get_uint32_data(cur_u8_data);
    
    n_objects = cur_u32_data(1,1);
    
    %DATA RESIZING --------------------------------------------------
    if cur_obj_index + n_objects > length(raw_obj__names)
        raw_obj__names    = [raw_obj__names    cell(1,INIT_OBJ_SIZE)]; 
        raw_obj__seg_id   = [raw_obj__seg_id   zeros(1,INIT_OBJ_SIZE)]; 
        raw_obj__idx_len  = [raw_obj__idx_len  zeros(1,INIT_OBJ_SIZE)];
        raw_obj__idx_data = [raw_obj__idx_data zeros(6,INIT_OBJ_SIZE,'uint32')];
    end
    
    cur_index = 4;
    raw_obj__seg_id(cur_obj_index+1:cur_obj_index+n_objects) = iSeg;
    for iObject = 1:n_objects
        cur_obj_index = cur_obj_index + 1;
        
        %NAME RETRIEVAL ---------------------------------------------------
        object_name_byte_length = cur_u32_data(cur_index+1);
        cur_index = cur_index + 4;
        %NOTE: Name is incorrect, but we'll fix it later
        raw_obj__names{cur_obj_index} = char(cur_u8_data((cur_index+1):(cur_index+object_name_byte_length)));
        cur_index = cur_index + object_name_byte_length;
        
        %INDEX LENGTH HANDLING --------------------------------------------
        index_length = cur_u32_data(cur_index+1);
        cur_index    = cur_index + 4;
        raw_obj__idx_len(cur_obj_index) = index_length;
        
        %NOTE: Ordered by likelihood
        if index_length == 20 %Grab 4 values
            raw_obj__idx_data(1:4,cur_obj_index) = cur_u32_data(cur_index+1:4:cur_index+13);
            cur_index = cur_index + 16;
        elseif index_length == MAX_INT || index_length == 0
            %do nothing
        elseif index_length == 28 %Grab 6 values
            raw_obj__idx_data(:,cur_obj_index)   = cur_u32_data(cur_index+1:4:cur_index+23);
            cur_index = cur_index + 24;
        else
            %TODO: Provide more information
            error('Unexpected index length')
        end
        
        %PROPERTY HANDLING
        %==================================================================
        n_properties = cur_u32_data(cur_index+1);
        cur_index    = cur_index + 4;
        
        %Property Resizing ------------------------------------------------
        if cur_prop_index + n_properties > length(prop__names)
            prop__names      = [prop__names      cell(1,INIT_PROP_SIZE)];
            prop__values     = [prop__values     cell(1,INIT_PROP_SIZE)];
            prop__raw_obj_id = [prop__raw_obj_id zeros(1,INIT_PROP_SIZE)];
            prop__types      = [prop__types      zeros(1,INIT_PROP_SIZE)]; 
        end
        
        prop__raw_obj_id(cur_prop_index+1:cur_prop_index+n_properties) = cur_obj_index;
        for iProp = 1:n_properties
            cur_prop_index = cur_prop_index + 1;
            
            %NAME RETRIEVAL -----------------------------------------------
            prop_name_byte_length = cur_u32_data(cur_index+1);
            cur_index = cur_index + 4;
            
            %NOTE: Name may be incorrect, will fix later ...
            prop__names{cur_prop_index} = char(cur_u8_data((cur_index+1):(cur_index+prop_name_byte_length)));
            cur_index = cur_index +  prop_name_byte_length;
            
            %TYPE RETRIEVAL -----------------------------------------------
            prop__types(cur_prop_index) = cur_u32_data(cur_index+1);
            cur_index = cur_index + 4;
            
            %VALUE RETRIEVAL ----------------------------------------------
            [prop__values{cur_prop_index},cur_index] = feval(fread_prop_info{prop__types(cur_prop_index)},cur_u8_data,cur_index);
        end
    end
    %TODO: Add raw data vs new object check ...
    %i.e. check raw data flag, add in code that looks for objects with new 
    %data
end

%Population of raw_meta object
%==========================================================================
obj.raw_obj__names        = raw_obj__names(1:cur_obj_index);
obj.raw_obj__seg_id       = raw_obj__seg_id(1:cur_obj_index);
obj.raw_obj__idx_len      = raw_obj__idx_len(1:cur_obj_index);
obj.raw_obj__has_raw_data = obj.raw_obj__idx_len ~= MAX_INT;

obj.n_raw_objs = cur_obj_index;

%Parsing of the idx_data
%-----------------------------------------------------------
obj.raw_obj__data_types        = raw_obj__idx_data(1,1:cur_obj_index);
%NOTE: Ignoring dimension - row 2, for now ...
obj.raw_obj__n_values_per_read = double(typecastC(raw_obj__idx_data(3:4,1:cur_obj_index),'uint64'))';
obj.raw_obj__n_bytes_per_read  = double(typecastC(raw_obj__idx_data(5:6,1:cur_obj_index),'uint64'))';
%NOTE: raw_obj__n_bytes_per_read is currently only for strings. We could
%try and update it here for non-strings, but many of these entries are set
%to a default value of zero, which means "use the previous value". We need
%to resolve this first, then we can make this property accurate for all
%entries.

obj.n_props           = cur_prop_index;
obj.prop__names       = prop__names(1:cur_prop_index);
obj.prop__values      = prop__values(1:cur_prop_index);
obj.prop__raw_obj_id  = prop__raw_obj_id(1:cur_prop_index);
obj.prop__types       = prop__types(1:cur_prop_index);


end

function cur_uint32_seg_data = get_uint32_data(cur_seg_meta_data)
n_1 = floor(0.25*length(cur_seg_meta_data));
n_2 = floor(0.25*(length(cur_seg_meta_data)-1));
n_3 = floor(0.25*(length(cur_seg_meta_data)-2));
n_4 = floor(0.25*(length(cur_seg_meta_data)-3));

cur_uint32_seg_data = zeros(4,n_1);

cur_uint32_seg_data(1,1:n_1) = double(typecast(cur_seg_meta_data(1:4*n_1),'uint32'));
cur_uint32_seg_data(2,1:n_2) = double(typecast(cur_seg_meta_data(2:(4*n_2+1)),'uint32'));
cur_uint32_seg_data(3,1:n_3) = double(typecast(cur_seg_meta_data(3:(4*n_3+2)),'uint32'));
cur_uint32_seg_data(4,1:n_4) = double(typecast(cur_seg_meta_data(4:(4*n_4+3)),'uint32'));
%NOTE: By going down rows for different shifts, indices
%will direcetly index into m
end
