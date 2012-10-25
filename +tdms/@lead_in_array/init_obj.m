function init_obj(obj,fid,reading_index_file)
%
%   init_obj(obj,fid,reading_index_file)
%
%
%IMPROVEMENTS:
%===============================
%NOTE: Instead of data_start, we could just keep track of data length ...
%
%   POPULATED PROPERTIES
%   =====================================================

%STATUS: I need 3 separate cases
%1) Index file exists, do all in memory
%2) Index file does not exist, but file is small
%3) No Index, LARGE file


%TODO: Move these out into the options property
%Populate these variables from the options variables
INIT_SIZE   = 10000;
GROWTH_SIZE = 10000;

LEAD_IN_BYTE_LENGTH = obj.LEAD_IN_BYTE_LENGTH;

%NOTE: This could be mexed rather easily



if reading_index_file
   first_word = typecast(uint8('TDSh'),'uint32');  
else
   first_word = typecast(uint8('TDSm'),'uint32'); 
end

readLeadInFromIndexFile(obj,fid,first_word)


% n_segs   = 0; %#ok<*PROP>
% 
% toc_mask    = zeros(1,INIT_SIZE,'uint32');
% meta_start  = zeros(1,INIT_SIZE); %Index or file related
% data_start  = zeros(1,INIT_SIZE); %File related only
% data_length = zeros(1,INIT_SIZE);
% 
% cur_data_position = 0;





% % % % % 
% % % % % 
% % % % % %CLEAN UP CODE
% % % % % %==========================================================================
% % % % % %1) Verify lead_in_flags
% % % % % 
% % % % % 
% % % % % 
% % % % % 
% % % % % keyboard
% % % % % 
% % % % % 
% % % % % 
% % % % % fseek(fid,0,-1);   
% % % % % tic
% % % % % while ftell(fid) ~= eofPosition
% % % % %     n_segs = n_segs + 1;
% % % % %     if n_segs > length(toc_mask)
% % % % %         %grow stuff
% % % % %         toc_mask    = [toc_mask    zeros(1,GROWTH_SIZE,'uint32')]; %#ok<AGROW>
% % % % %         meta_start  = [meta_start  zeros(1,GROWTH_SIZE)]; %#ok<AGROW>
% % % % %         data_start  = [data_start  zeros(1,GROWTH_SIZE)]; %#ok<AGROW>
% % % % %         data_length = [data_length zeros(1,GROWTH_SIZE)]; %#ok<AGROW>
% % % % %     end
% % % % %     
% % % % %     %NOTE: Would be faster to remove function ... :/
% % % % %     %But it wouldn't be as clean ...
% % % % %     [lead_in_array,lengths]    = readLeadIn(obj,fid,first_word);
% % % % %     
% % % % %     toc_mask(n_segs)   = lead_in_array(2);
% % % % %     cur_data_position  = cur_data_position + LEAD_IN_BYTE_LENGTH;
% % % % %     
% % % % %     meta_start(n_segs) = ftell(fid); %Don't use cur_data_position
% % % % %     %Could be reading from the index
% % % % %     
% % % % %     %NOTE: We're going to ignore version number for now ...
% % % % % 
% % % % %     %NOTE: Lengths ignore the lead_in
% % % % %     %We could also speed this up by saving seg_length and meta_length
% % % % %     %and computing all of this afterwards ...
% % % % %     seg_length          = lengths(1);
% % % % %     meta_length         = lengths(2); 
% % % % %     data_length(n_segs) = seg_length - meta_length;
% % % % %     
% % % % %     %NOTE: For rawDAQmx, this might be problematic :/
% % % % %     
% % % % %     if reading_index_file
% % % % %         fseek(fid,meta_length,0);
% % % % %     else
% % % % %         fseek(fid,seg_length,0);
% % % % %     end
% % % % %     
% % % % %     data_start(n_segs)  = cur_data_position + meta_length;
% % % % %     cur_data_position   = cur_data_position + seg_length;
% % % % % end
% % % % % toc
% % % % % 
% % % % % obj.n_segs      = n_segs;
% % % % % obj.data_start  = data_start(1:n_segs);
% % % % % obj.meta_start  = meta_start(1:n_segs);
% % % % % obj.toc_mask    = toc_mask(1:n_segs);
% % % % % obj.data_length = data_length(1:n_segs);


end