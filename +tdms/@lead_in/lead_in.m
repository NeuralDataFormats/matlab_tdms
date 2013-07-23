classdef lead_in < handle
    %
    %   Class:
    %   tdms.lead_in
    %
    %   METHODS
    %   =======================================
    %   tdms.lead_in.readLeadInFromIndexFile
    %   tdms.lead_in.readLeadInFromDataFile
    %
    %   DESIGN DECISIONS
    %   ===================================================================
    %   1) Originally the lead in was specifically meant to handle
    %   only the lead in portion of the reading, and not anything
    %   related to the meta data. An array of lead in objects proved to be
    %   way too slow so instead more processing was done in this code and
    %   this class thus provides a summary of ALL lead ins, not just a
    %   single one.
    
    
    properties (Hidden)
        first_word   %(uint32) First four bytes of each lead in, this varies
        %depending on whether you are reading the index file or the data
        %file.
        toc_masks    %Instructions for each segment. See the flags.
    end
    
    %FLAGS  ===============================================================
    properties (Dependent)
        d2 = '----  Output Flags ----'
        has_meta_data   %Indicates whether or not new property values have
        %been defined. %todo: find code that uses this and point to it
        new_obj_list    %Whether or not to reset the read order for objects.
        has_raw_data    %Whether or not this segment contains
        is_interleaved  %
        is_big_endian
        has_raw_daqmx   %TODO: Provide section describing raw_daqmx
    end
    
    properties
        d3 = '----    Outputs    ----'
        invalid_segment_found = false %If true this indicates
        %TODO: We might want a reason ...
        %reasons:
        %1) - invalid lead in
        %2) - size specification exceeds file size
        
        n_segs  %# of segments
        data_starts     %(double, row vector) byte index in data file where reading starts
        data_lengths    %(double, row vector) byte lengths of all segments
        
        raw_meta_data   %({1 x n_segs} uint8 array), unprocessed meta data
        %for all segments
    end
    
    properties (Constant)
        LEAD_IN_BYTE_LENGTH = 28;
    end
    
    %TOC_MASK PARSING FUNCTIONS ===========================================
    methods
        function value = get.has_meta_data(obj)
            value = bitget(obj.toc_masks,2);
        end
        function value = get.new_obj_list(obj)
            value = bitget(obj.toc_masks,3);
        end
        function value = get.has_raw_data(obj)
            value = bitget(obj.toc_masks,4);
        end
        function value = get.is_interleaved(obj)
            value = bitget(obj.toc_masks,6);
        end
        function value = get.is_big_endian(obj)
            value = bitget(obj.toc_masks,7);
        end
        function value = get.has_raw_daqmx(obj)
            value = bitget(obj.toc_masks,8);
        end
    end
    
    methods
        function obj = lead_in(options,fid,reading_index_file)
            
            %TODO: Consider not holding onto fid, pass into
            %options
            obj.populateFirstWord(reading_index_file);
            
            if reading_index_file
                %tdms.lead_in.readLeadInFromIndexFile
                obj.readLeadInFromIndexFile(options,fid);
            else
                fseek(fid,0,1);
                eof_position = ftell(fid);
                fseek(fid,0,-1);
                
                if options.meta__data_in_mem_rule == 0
                    obj.readLeadInFromDataFile(eof_position,options,fid);
                elseif options.meta__data_in_mem_rule == 1
                    n_MB_data = eof_position/1e6;
                    if n_MB_data < options.meta__max_MB_process_data_in_mem
                        obj.readLeadInFromInMemData(options,fid);
                    else
                        obj.readLeadInFromDataFile(eof_position,options,fid);
                    end
                else
                    obj.readLeadInFromInMemData(options,fid);
                end
            end
            
            obj.checkTocMask();
        end
        function checkTocMask(obj)
            %checkTocMask
            %
            %    checkTocMask(obj)
            %
            %    Checks the toc mask for flags which will currently cause
            %    problems.
            
            if any(obj.is_big_endian)
                tdms.error('e001__bigEndian',...
                    'Currently reading of files with big endian ordering is unsupported')
            end
            if any(obj.has_raw_daqmx)
                
            end
        end
        function populateRawDataStarts(obj,meta_lengths,seg_lengths)
            %populateRawDataStarts Populates .data_starts property
            %
            %    populateRawDataStarts(obj,meta_lengths,seg_lengths)
            %
            %    meta_lengths - length of the meta data in bytes for each segment
            %    seg_lengths  - length of meta data & raw data in bytes "  "
            %
            %    NOTE: Each meta/raw data section is proceeded by a 28 byte length lead in
            
            %Raw Data Starts
            %---------------------------------------------------------------
            %1 - 28*1 + 0                + meta(1)
            %2 - 28*2 + seg_lengths(1)   + meta(2)
            %3 - 28*3 + seg_lengths(1:2) + meta(3)
            
            seg_lengths_shifted = [0 seg_lengths(1:end-1)];
            obj.data_starts = cumsum(28 + seg_lengths_shifted) + meta_lengths;
            
        end
        function populateFirstWord(obj,reading_index_file)
            if reading_index_file
                obj.first_word = typecast(uint8('TDSh'),'uint32');
            else
                obj.first_word = typecast(uint8('TDSm'),'uint32');
            end
        end
    end
end

