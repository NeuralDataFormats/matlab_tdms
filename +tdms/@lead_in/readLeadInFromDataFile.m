function readLeadInFromDataFile(obj,eof_position,options,fid)
%
%
%   tdms.lead_in.readLeadInFromDataFile
%
%
%   See Also:
%   tdms.lead_in.readLeadInFromIndexFile
%   tdms.lead_in.readLeadInFromInMemData

GROWTH_SIZE = options.lead_in_growth_size;
INIT_SIZE   = options.lead_in_init_size;

first_word = obj.first_word;

lead_in_data  = zeros(7,INIT_SIZE,'uint32');
raw_meta_data = cell(1,INIT_SIZE);
n_segs        = 0;
keep_reading = true;

%This is fairly slow and could be mexed
%--------------------------------------------------------------------------

try
    while keep_reading
        n_segs = n_segs + 1;
        
        if n_segs > size(lead_in_data,2)
            lead_in_data  = [lead_in_data   zeros(7,GROWTH_SIZE,'uint32')]; %#ok<AGROW>
            raw_meta_data = [raw_meta_data  cell(1,GROWTH_SIZE)]; %#ok<AGROW>
        end
        
        %TODO: Check for the unexpected quit id
        
        temp = fread(fid,7,'*uint32');
        if temp(1) ~= first_word
            n_segs = n_segs - 1;
            
            keep_reading = false;
            obj.invalid_segment_found = true;
            if ~options.read_file_until_error
               error('Invalid lead in detected')
            else
               %TODO: Populate reason property 
            end
        else
            %Hold onto lead in data
            lead_in_data(:,n_segs) = temp;
            
            %Grab info for advancing and for reading meta
            seg_length  = typecast(temp(4:5),'uint64');
            meta_length = typecast(temp(6:7),'uint64');
            
            %Read meta
            %----------
            %NOTE: In order for propert conversion to character the 
            %dimension of [1 x meta_length] is needed rather than just 
            %meta_length
            raw_meta_data{n_segs} = fread(fid,[1 meta_length],'*uint8');
            
            %Advance to next segment
            fseek(fid,double(seg_length-meta_length),0); %The double() kills me
            %Double is needed because fseek requires double as an input for
            %the origin specifier (or char).
            
            keep_reading = ftell(fid) < eof_position;
        end
    end
catch ME
    %I'm not sure why we would ever get here ...
    rethrow(ME)
% if invalid_segment_found
% if options.read_file_until_error
% 
% else
% 
% end
% end
end

obj.raw_meta_data = raw_meta_data(1:n_segs);

lead_in_data(:,n_segs+1:end) = []; %truncate overly allocated data

seg_lengths   = double(tdms.sl.io.typecastC(lead_in_data(4:5,:),'uint64'))';
meta_lengths  = double(tdms.sl.io.typecastC(lead_in_data(6:7,:),'uint64'))';

obj.toc_masks = lead_in_data(2,:);

obj.populateRawDataStarts(meta_lengths,seg_lengths);

obj.data_lengths = seg_lengths - meta_lengths;
