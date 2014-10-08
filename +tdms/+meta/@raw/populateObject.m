function populateObject(obj)
%
%   tdms.meta.raw.populateObject
%
%   At this point we loop through the meta data extracting all of the
%   information that is contained in it. This includes the names of all 
%   objects, whether or not they have data, how much data they have, and
%   whether or not they have properties and the associated property values.
%   
%   We will need to process this information further, but the use
%   of the raw meta data from the initial read will no longer be needed.
%   After this everything is in specific variables as specified in this
%   object.



%This code has been rewritten to only process unique entries. This speedup
%can be significant in cases where one set of channels is written to, and
%then another set of channels is written to, back and forth. When this
%happens the writer needs to create small meta headers each time the set of
%channels being written to switches.
%
%Since extracting the information from the header can take time

fread_prop_info = tdms.props.get_prop_fread_functions;

%MLINT:
%------
%#ok<*AGROW>  %Autogrow ok


%Lead In Data Extraction:
%------------------------
%Each cell contains the raw meta information (uint8) for one segement.
raw_meta_data_cells = obj.lead_in.raw_meta_data;

%We convert to char because unique doesn't work on cell arrays of uint8s :/
as_char = cellfun(@char,raw_meta_data_cells,'un',0);

[unique_raw_metas_as_char,seg_id_of_unique] = unique(as_char,'stable');

unique_raw_metas_as_uint8 = raw_meta_data_cells(seg_id_of_unique);

obj.n_unique_meta_segments = length(unique_raw_metas_as_char);
obj.n_segments = length(raw_meta_data_cells);


MAX_INT        = 2^32-1;
INIT_OBJ_SIZE  = obj.options.raw__INIT_OBJ_SIZE;
INIT_PROP_SIZE = obj.options.raw__INIT_PROP_SIZE;

%PROPERTY HANDLING
%--------------------------------------------------------------------------
prop__names      = cell(1,INIT_PROP_SIZE);
prop__values     = cell(1,INIT_PROP_SIZE);
prop__raw_obj_id = zeros(1,INIT_PROP_SIZE);
prop__types      = zeros(1,INIT_PROP_SIZE);
cur_prop_index   = 0;

cur_obj_count = 0;

n_unique_segments = length(unique_raw_metas_as_char);

unique_seg_info = cell(1,n_unique_segments);
for i_seg = 1:n_unique_segments
    cur_u8_data   = unique_raw_metas_as_uint8{i_seg};
    
    cur_u32_data = get_uint32_data(cur_u8_data);
    
    n_objects = cur_u32_data(1,1);
    
    obj_names    = cell(1,n_objects);
    obj_idx_len  = zeros(1,n_objects);
    obj_idx_data = zeros(6,n_objects,'uint32');
    obj_id       = (cur_obj_count+1):(cur_obj_count + n_objects);
        
    next_u8_index = 5;
    for iObject = 1:n_objects
        cur_obj_count = cur_obj_count + 1;
        
        
        %NAME RETRIEVAL ---------------------------------------------------
        byte_length_cur_obj_name = cur_u32_data(next_u8_index);
        next_u8_index = next_u8_index + 4;
        
        %NOTE: Name is incorrect, but we'll fix it later
        obj_names{iObject} = char(cur_u8_data((next_u8_index):(next_u8_index+byte_length_cur_obj_name-1)));
        next_u8_index = next_u8_index + byte_length_cur_obj_name;
        
        %INDEX LENGTH HANDLING --------------------------------------------
        index_length = cur_u32_data(next_u8_index);
        next_u8_index    = next_u8_index + 4;
        obj_idx_len(iObject) = index_length;
        
        %NOTE: Ordered by likelihood
        if index_length == 20 %Grab 4 values
            obj_idx_data(1:4,iObject) = cur_u32_data(next_u8_index:4:next_u8_index+12);
            next_u8_index = next_u8_index + 16;
        elseif index_length == MAX_INT || index_length == 0
            %do nothing
        elseif index_length == 28 %Grab 6 values
            obj_idx_data(:,iObject)   = cur_u32_data(next_u8_index:4:next_u8_index+20);
            next_u8_index = next_u8_index + 24;
        else
            %TODO: Provide more information
            error('Unexpected index length')
        end
        
        %PROPERTY HANDLING:
        %-------------------------------------------
        n_properties  = cur_u32_data(next_u8_index);
        next_u8_index = next_u8_index + 4;
        
        %Property Resizing ------------------------------------------------
        if cur_prop_index + n_properties > length(prop__names)
            prop__names      = [prop__names      cell(1,INIT_PROP_SIZE)];
            prop__values     = [prop__values     cell(1,INIT_PROP_SIZE)];
            prop__raw_obj_id = [prop__raw_obj_id zeros(1,INIT_PROP_SIZE)];
            prop__types      = [prop__types      zeros(1,INIT_PROP_SIZE)]; 
        end
        
        prop__raw_obj_id(cur_prop_index+1:cur_prop_index+n_properties) = cur_obj_count;
        for iProp = 1:n_properties
            cur_prop_index = cur_prop_index + 1;
            
            %NAME RETRIEVAL -----------------------------------------------
            prop_name_byte_length = cur_u32_data(next_u8_index);
            next_u8_index = next_u8_index + 4;
            
            %NOTE: Name may be incorrect, will fix later ...
            prop__names{cur_prop_index} = char(cur_u8_data((next_u8_index):(next_u8_index+prop_name_byte_length-1)));
            next_u8_index = next_u8_index +  prop_name_byte_length;
            
            %TYPE RETRIEVAL -----------------------------------------------
            prop__types(cur_prop_index) = cur_u32_data(next_u8_index);
            next_u8_index = next_u8_index + 4;
            
            %VALUE RETRIEVAL ----------------------------------------------
            %NOTE: double step function assignment might be quicker
            %f = fread_prop_info{prop__types(cur_prop_index)}
            %f(cur_u8_data,cur_index);
            [prop__values{cur_prop_index},next_u8_index] = feval(fread_prop_info{prop__types(cur_prop_index)},cur_u8_data,next_u8_index);
        end
    end
    
    temp = tdms.meta.unique_raw_segment();
    temp.first_seg_id = seg_id_of_unique(i_seg);
    temp.obj_names    = obj_names;
    temp.obj_idx_len  = obj_idx_len;
    temp.obj_idx_data = obj_idx_data;
    temp.obj_id       = obj_id;
    unique_seg_info{i_seg} = temp;
end

obj.unique_segment_info = [unique_seg_info{:}];

%Property populating
%--------------------------------------------------------------------------
obj.n_props           = cur_prop_index;
obj.prop__names       = prop__names(1:cur_prop_index);
obj.prop__values      = prop__values(1:cur_prop_index);
obj.prop__raw_obj_id  = prop__raw_obj_id(1:cur_prop_index);
obj.prop__types       = prop__types(1:cur_prop_index);

end

function cur_uint32_seg_data = get_uint32_data(cur_seg_meta_data)
%
%   JAH TODO: Document this function
%
%   To avoid multiple typecasting calls we typecast different shifts
%   of the data. This leads to a bit of memory inflation but since
%   we are working on a small bit of data it isn't expected to have a big
%   impact. This guarantees that we only do 4 typecast calls, not a
%   typecast per uint32 encountered.
%
%   This looks wrong, fix it
%
%   Why are we converting to double????? - that seems wrong ...
%

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
