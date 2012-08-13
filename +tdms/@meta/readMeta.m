function readMeta(obj)
%
%   NAME: tdms.meta.readMeta

import tdms.*

MAX_INT = 2^32-1;
INIT_OBJ_SIZE  = 1000;
INIT_PROP_SIZE = 1000;
INIT_READ_SIZE = 100000;

fid = obj.fid;

[fread_prop_info,nBytesByType] = get_meta_read_instructions(obj);

lead_in_obj       = lead_in_array(obj.fid,obj.reading_index_file);
obj.lead_in       = lead_in_obj;

li_has_raw_data   = lead_in_obj.has_raw_data;
li_has_meta_data  = lead_in_obj.has_meta_data;
li_new_obj_list   = lead_in_obj.new_obj_list;

%READ INSTRUCTIONS
%=============================================

raw_n_values_read  = zeros(1,INIT_READ_SIZE);
raw_n_bytes_read   = zeros(1,INIT_READ_SIZE); %needed for strings - actually, maybe, might only need for getting starts ...
raw_chan_id        = zeros(1,INIT_READ_SIZE);
raw_index_start    = zeros(1,lead_in_obj.n_segs);
n_seg_reads = 0;            
            
            
%BY CHANNEL VARIABLES
%==============================================

obj_index_in_cr      = zeros(1,INIT_OBJ_SIZE); %check this for appendings
obj_n_vals_per_read  = zeros(1,INIT_OBJ_SIZE);
obj_n_bytes_per_read = zeros(1,INIT_OBJ_SIZE); %for strings ...
obj_data_type        = zeros(1,INIT_OBJ_SIZE);
obj_names            = cell(1,INIT_OBJ_SIZE);
n_objs               = 0;


%BY CUR READ VARIABLES
%==============================================
cr_obj_order        = zeros(1,INIT_OBJ_SIZE); %NOTE: this isn't by object 
cr_n_bytes_per_read = zeros(1,INIT_OBJ_SIZE);
cr_n_vals_per_read  = zeros(1,INIT_OBJ_SIZE);
cr_n_objs     = 0;




prop_names      = cell(1,INIT_PROP_SIZE);
prop_vals       = cell(1,INIT_PROP_SIZE);
prop_chan_ids   = zeros(1,INIT_PROP_SIZE);
prop_data_type  = zeros(1,INIT_PROP_SIZE);
n_props_total   = 0;



meta_starts = lead_in_obj.meta_start;

%WRONG
byte_size_raw = lead_in_obj.data_start - meta_starts;

for iSeg = 1:lead_in_obj.n_segs
  
   %OUTLINE
   %-----------------------
   %- new obj list
   %- num new segments
   
   fseek(fid,meta_starts(iSeg),-1);
   
   %META PROCESSING
   %=======================================================================
   if li_has_meta_data(iSeg)
      number_new_objs_in_segment = fread(fid,1,'uint32');
      
      if li_new_obj_list(iSeg)
         obj_index_in_cr(cr_obj_order(1:cr_n_objs)) = 0;
         cr_n_objs = 0; 
      end
      
      %Loop over objects with new props or raw info reading instructions
      %----------------------------------------
      for iObj = 1:number_new_objs_in_segment
            %1) GET OBJECT PATH
            %----------------------------------------
            %Ideally we could keep as uint8 and do char only at the end
            cur_obj_name = fread(fid,fread(fid,1,'uint32'),'uint8=>char')';
            
            %2) GETTING OBJECT INDEX
            %----------------------------------------
            obj_index = find(strcmp(obj_names(1:n_objs),cur_obj_name),1);
            if isempty(obj_index)
                obj_index = n_objs + 1;
                %TODO: Implement resize code if necessary ...
                n_objs    = obj_index;
                obj_names{obj_index} = cur_obj_name;
            end
            
            %3) RAW DATA INFO
            %-------------------------------------------
            raw_data_index_length = fread(fid,1,'uint32');
            cr_index = 0;
            switch raw_data_index_length
                case 0
                    %Same as last raw data specification
                    if ~obj_index_in_cr(obj_index)
                       cr_n_objs = cr_n_objs + 1; 
                       cr_index  = cr_n_objs;
                       obj_index_in_cr(obj_index) = cr_index;
                    end
                case MAX_INT
                    %No raw data, if present in list, need to delete ...
                    if obj_index_in_cr(obj_index)
                        error('List removal not yet implemented')
                    end
                otherwise
                    data_type_temp  = fread(fid,1,'uint32');
                    if fread(fid,1,'uint32') ~= 1, error('1D array assumed'), end
                    obj_n_vals_per_read(obj_index) = fread(fid,1,'uint64');
                    
                    %Better as a function?
                    if data_type_temp == 32
                        obj_n_bytes_per_read(obj_index) = fread(fid,1,'uint64');
                    else
                        obj_n_bytes_per_read(obj_index) = nBytesByType(data_type_temp);
                    end
                    obj_data_type(obj_index) = data_type_temp;
                    
                    cr_index = obj_index_in_cr(obj_index);
                    if cr_index == 0
                       cr_n_objs = cr_n_objs + 1; 
                       cr_index  = cr_n_objs;
                       obj_index_in_cr(obj_index) = cr_index;
                    end
                    
            end

            %Adding channel onto current read list
            if cr_index ~= 0
                cr_obj_order(cr_n_objs)        = obj_index;
                cr_n_bytes_per_read(cr_n_objs) = obj_n_bytes_per_read(obj_index);
                cr_n_vals_per_read(cr_n_objs)  = obj_n_vals_per_read(obj_index);
            end

            %Property Reading 
            %-----------------------------------------------------
            for iProp = 1:fread(fid,1,'uint32')
               n_props_total = n_props_total + 1;
               prop_names{n_props_total}     = fread(fid,fread(fid,1,'uint32'),'uint8=>char')';
               temp_type                     = fread(fid,1,'uint32');
               prop_data_type(n_props_total) = temp_type; %for fixing timestamp after the fact
                                               %might move to doing this later ...
               prop_vals{n_props_total}      = feval(fread_prop_info{temp_type},fid);
               prop_chan_ids(n_props_total)  = obj_index;
            end
            
      end
   end
    
   
    %NOTE: I don't currently hold onto the data type
    %Assume it doesn't change ... - reference back to obj
    if li_has_raw_data(iSeg) && byte_size_raw(iSeg) ~= 0
        %NOTE: apparently it is valid to say raw data is present
        %even if there is none present ...
        indices                     = n_seg_reads+1:n_seg_reads+cr_n_objs;
        raw_n_bytes_read(indices)   = cr_n_bytes_per_read(1:cr_n_objs);
        raw_n_values_read(indices)  = cr_n_vals_per_read(1:cr_n_objs);
        raw_chan_id(indices)        = cr_obj_order(1:cr_n_objs);
        raw_index_start(iSeg)       = n_seg_reads+1;
        n_seg_reads                 = n_seg_reads + cr_n_objs;
    end
   
end



obj.raw_n_bytes_read    = raw_n_bytes_read;
obj.raw_n_values_read   = raw_n_values_read;
obj.raw_index_start     = raw_index_start;
obj.raw_chan_id         = raw_chan_id;
obj.n_seg_reads         = n_seg_reads;

obj.n_props_total = n_props_total;
obj.prop_names = prop_names;
obj.prop_vals = prop_vals;
obj.prop_chan_ids = prop_chan_ids;

fclose(fid);



%start nSamples channel_or_GroupId interleaved


%NOTE: Move this into a different section
%RAW DATA
%---------------------------
%INPUTS
%byteSizeRaw


end
