function readLeadInFromDataFile(obj,eof_position,options,fid)
%
%
%
%   IMPROVEMENTS
%   =======================================================================
%   1) At some point I had considered allowing reading of the entire file.
%
%   See Also:
%   tdms.lead_in.readLeadInFromIndexFile
%   tdms.lead_in.readLeadInFromInMemData

error('Unfinished')

GROWTH_SIZE = options.lead_in_growth_size;
INIT_SIZE   = options.lead_in_init_size;

first_word = obj.first_word;

lead_in_data  = zeros(7,INIT_SIZE,'uint32');
raw_meta_data = cell(1,INIT_SIZE);
n_segs        = 0;
invalid_segment_found = false;
keep_reading = true;


%TODO: Update to be like the other

%This is fairly slow and could be mexed
%--------------------------------------------------------------------------

try
    while keep_reading
        n_segs = n_segs + 1;
        
        if n_segs > size(lead_in_data,2)
            lead_in_data  = [lead_in_data zeros(7,GROWTH_SIZE,'uint32')]; %#ok<AGROW>
            raw_meta_data = [raw_meta_data cell(1,GROWTH_SIZE)]; %#ok<AGROW>
        end
        
        temp = fread(fid,7,'*uint32');
        if temp(1) ~= first_word
            n_segs = n_segs - 1;
            
            keep_reading = false;
            invalid_segment_found = true;
            if ~options.read_file_until_error
               error('Invalid lead in detected')
            else
               %TODO: Populate reason property 
            end
        else
            %Grab meta data
            %advance index
            %hold onto lead in data
            
            lead_in_data(:,n_segs) = temp;
            
            seg_length  = typecast(temp(4:5),'uint64');
            meta_length = typecast(temp(6:7),'uint64');
            
            raw_meta_data{n_segs} = fread(fid,meta_length,'*uint8');
            fseek(fid,double(seg_length-meta_length),0); %The double() kills me
            %Double is needed because fseek requires double as an input for
            %the origin specifier (or char).
            
            keep_reading = ftell(fid) < eof_position;
        end
    end
catch ME
    rethrow(ME)
% if invalid_segment_found
% if options.read_file_until_error
% 
% else
% 
% end
% end
end

obj.invalid_segment_found = invalid_segment_found;

lead_in_data(:,n_segs+1:end) = []; %truncate overly allocated data
%TODO: Truncate sizes ...

seg_lengths   = double(typecastC(lead_in_data(4:5,:),'uint64'))';
meta_lengths  = double(typecastC(lead_in_data(6:7,:),'uint64'))';
