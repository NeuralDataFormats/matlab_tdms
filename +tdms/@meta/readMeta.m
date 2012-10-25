function readMeta(obj)
%readMeta
%
%   NAME: tdms.meta.readMeta

import tdms.*

MAX_INT        = 2^32-1;
INIT_OBJ_SIZE  = 1000;
INIT_PROP_SIZE = 1000;
INIT_READ_SIZE = 100000;

fid = obj.fid;

n_bytes_by_type = getNBytesByTypeArray(obj);
fread_prop_info = props.get_prop_fread_functions;



lead_in_obj       = lead_in_array(obj.fid,obj.reading_index_file);
obj.lead_in       = lead_in_obj;

leadin_has_raw_data   = lead_in_obj.has_raw_data;
leadin_has_meta_data  = lead_in_obj.has_meta_data;
leadin_new_obj_list   = lead_in_obj.new_obj_list;

%READ INSTRUCTIONS
%=============================================

raw_n_values_read  = zeros(1,INIT_READ_SIZE); 
raw_n_bytes_read   = zeros(1,INIT_READ_SIZE); %needed for strings 
%- actually, maybe, might only need for getting starts ...
raw_chan_id        = zeros(1,INIT_READ_SIZE); %
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



%PROPERTY HANDLING
%===============================================
prop_names      = cell(1,INIT_PROP_SIZE);
prop_vals       = cell(1,INIT_PROP_SIZE);
prop_chan_ids   = zeros(1,INIT_PROP_SIZE);
prop_is_timestamp  = false(1,INIT_PROP_SIZE);
n_props_total   = 0;

meta_data = obj.lead_in.meta_data;

%THINGS TO SAVE IN THE LOOP
%--------------------------------------
%object
%index length
%

for iSeg = 1:obj.lead_in.n_segs
   cur_meta = meta_data{iSeg};
   
   %NOTE: It would be nice if I could make this prettier ...
   %NOTE: I could do this in a loop - just get from a function 
   
   
   n_1 = floor(0.25*length(cur_meta));
   n_2 = floor(0.25*(length(cur_meta)-1));
   n_3 = floor(0.25*(length(cur_meta)-2));
   n_4 = floor(0.25*(length(cur_meta)-3));
   
   %m = zeros(n_1,4,'uint32');   %Or do I make this double?
   
   m = cell(1,4);
   m{1} = typecast(cur_meta(1:4*n_1),'uint32');
   m{2} = typecast(cur_meta(2:(4*n_2+1)),'uint32');
   m{3} = typecast(cur_meta(3:(4*n_3+2)),'uint32');
   m{4} = typecast(cur_meta(4:(4*n_4+3)),'uint32');
   indices = zeros(1,n_1*4); %NOTE: use bsxfun or matrix multiplication
   %indices = ones(4,1)*(1:(n_1/4));
   %indices = repmat(1:(n_1/4),4,1);
   %I can't believe this freaking works for speed :/
   indices(1:4:end) = 1:n_1;
   indices(2:4:end) = 1:n_1;
   indices(3:4:end) = 1:n_1;
   indices(4:4:end) = 1:n_1;
   
   %NOTE: Properties and strings are where we might change uint32 alignment
   
   n_objects = m{1}(1);

   cur_index = 4;
   word_align = 1;
   for iObject = 1:n_objects
      %object_name_byte_length = typecast(cur_meta((cur_index+1):(cur_index+4)),'uint32');
      object_name_byte_length = m{word_align}(indices(cur_index+1));  
      
%       if object_name_byte_length ~= object_name_byte_length2
%           keyboard
%       end
      
      %object_name = local_native2unicode(cur_meta((cur_index+5):(cur_index+4+object_name_byte_length)))
      
      cur_index = cur_index + 4 + object_name_byte_length;
      
      word_align = mod(cur_index,4)+1;
      
      %NOTE: I skipped reading the objects name here, come back to this later
      
      %index_length   = typecast(cur_meta((cur_index+1):(cur_index+4)),'uint32');
     index_length   = m{word_align}(indices(cur_index+1));
      
%       if index_length ~= index_length2
%           keyboard
%       end
      
      if index_length ~= MAX_INT
          cur_index = cur_index + index_length;
      else
          cur_index = cur_index + 4;
      end
      
      word_align = mod(cur_index,4)+1;
      
      %NOTE: It looks like there is no way to skip the damn properties ...
     % n_properties = typecast(cur_meta((cur_index+1):(cur_index+4)),'uint32');
      
      n_properties   = m{word_align}(indices(cur_index+1));
      
%       if n_properties ~= n_properties2
%           keyboard
%       end
      
      cur_index = cur_index + 4;
      for iProp = 1:n_properties
%           prop_name_byte_length = typecast(cur_meta((cur_index+1):(cur_index+4)),'uint32');
          prop_name_byte_length = m{word_align}(indices(cur_index+1));
          
%           if prop_name_byte_length ~= prop_name_byte_length2
%               
%               keyboard
%           end
          
          %prop_name = local_native2unicode(cur_meta((cur_index+5):(cur_index+4+prop_name_byte_length)))
          
          cur_index = cur_index + 4 + prop_name_byte_length;
          
          %NOTE: I might be able to type convert less here ...
          
          word_align = mod(cur_index,4)+1;
          
%           prop_type = typecast(cur_meta((cur_index+1):(cur_index+4)),'uint32');
          prop_type = m{word_align}(indices(cur_index+1));
%           if prop_type ~= prop_type2
%               keyboard
%           end
          
          if prop_type == 32
              prop_string_length = typecast(cur_meta((cur_index+5):(cur_index+8)),'uint32');
              cur_index = cur_index + 8 + prop_string_length;
          else
              cur_index = cur_index + 4 + n_bytes_by_type(prop_type);
          end
          
          word_align = mod(cur_index,4)+1;
      end
   end
   
end

return








meta_starts = lead_in_obj.meta_start;

%WRONG
byte_size_raw = lead_in_obj.data_length;

%Could I do channel reads here and reduce 
%strcmp later ???
%Does unique2 work on strings?
%
%Can I know the # of reads ahead of time ...
%based on this ...
%NOTE: I think I should be able to
%
%- note, for unique 2, creating an original
%index you init to full size and then assign
%each
%unique_index_all(uI(incrementer)) = incrementor;
%
%NOTE: this approach might be a lot faster
%since strcmp compares against all strings
%before then finding 1 match :/ => silly Matlab
% for iSeg = 1:lead_in_obj.n_segs
%    %get all channel specs     
% end

%For a real perverse optimization, I could 
%read as uint32, shifted 4x, and then do a mod on the seek
%position to know which of these shifts to use


%============================
%JAH: move into second version for index only
%===============================

% % % fseek(fid,0,-1);
% % % 
% % % %7363
% % % %7356
% % % 
% % % uint8_all = fread(fid,Inf,'*uint8');
% % % end_use = floor(0.25*(length(uint8_all)-3))*4;
% % % uint32_all = [typecast(uint8_all(1:end_use),'uint32')';...
% % %               typecast(uint8_all(2:end_use+1),'uint32')';...
% % %               typecast(uint8_all(3:end_use+2),'uint32')';...
% % %               typecast(uint8_all(4:end_use+3),'uint32')';];
% % % 
% % % uint32_all = uint32_all(:)';
% % %           
%n_objs_in_segment = uint32_all(meta_starts+1)

%NOTE: At this point we now know how to initialize the 
%reading of the strings - how many we'll have
%
%?? - how to skip btwn strings ???
          
          
for iSeg = 1:lead_in_obj.n_segs
  
   %OUTLINE
   %-----------------------
   %- new obj list
   %- num new segments
   
   fseek(fid,meta_starts(iSeg),-1);
   
   %META PROCESSING
   %=======================================================================
   if leadin_has_meta_data(iSeg)
      number_new_objs_in_segment = fread(fid,1,'uint32');
      
      if leadin_new_obj_list(iSeg)
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
            %NOTE: Would be really nice to have this be a function
            %INPUTS
            %- fid
            %OUTPUTS
            %- raw_data_index_length - not even sure what this is ...
            %
            %
            %
            %- data_type
            %
            %------------------
            %- cr_index
            %- cr_n_objs
            %- obj_index_in_cr
            
            
            cr_index = obj_index_in_cr(obj_index);
            
            raw_data_index_length = fread(fid,1,'uint32');
            switch raw_data_index_length
                case 0
                    %Same as last raw data specification
                    if cr_index == 0
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
                        obj_n_bytes_per_read(obj_index) = n_bytes_by_type(data_type_temp)*obj_n_vals_per_read(obj_index);
                    end
                    obj_data_type(obj_index) = data_type_temp;
                    
                    
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
               [prop_vals{n_props_total},prop_is_timestamp(n_props_total)] = ...
                   feval(fread_prop_info{fread(fid,1,'uint32')},fid);
               prop_chan_ids(n_props_total)  = obj_index;
            end
            
      end
   end
    
   
    %NOTE: I don't currently hold onto the data type
    %Assume it doesn't change ... - reference back to obj
    if leadin_has_raw_data(iSeg) && byte_size_raw(iSeg) ~= 0
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

raw_data_type = obj_data_type(raw_chan_id(1:n_seg_reads));

%Need to handle this better ...
%prop_vals(prop_is_timestamp(1:n_props_total)) = ...
%    cellfun(@to_timestamp,prop_vals(prop_is_timestamp(1:n_props_total)));


%raw_n_bytes_read(

obj.raw_n_bytes_read    = raw_n_bytes_read;
obj.raw_n_values_read   = raw_n_values_read;
obj.raw_index_start     = raw_index_start;
obj.raw_chan_id         = raw_chan_id;
obj.raw_data_type       = raw_data_type;
obj.n_seg_reads         = n_seg_reads;

obj.props = props(...
    prop_names(1:n_props_total),...
    prop_vals(1:n_props_total),...
    prop_chan_ids(1:n_props_total),...
    n_objs);%call constructor

fclose(fid);



%start nSamples channel_or_GroupId interleaved


%NOTE: Move this into a different section
%RAW DATA
%---------------------------
%INPUTS
%byteSizeRaw


end

function str_out = local_native2unicode(uint8_in)
    STR_ENCODING = 'UTF-8';
    str_out = native2unicode(uint8_in,STR_ENCODING);
end