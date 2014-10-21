classdef lead_in < sl.obj.handle_light
    %
    %   Class:
    %   tdms.lead_in
    %
    %   Methods:
    %   --------
    %   tdms.lead_in.readLeadInFromIndexFile
    %   tdms.lead_in.readLeadInFromDataFile
    %   tdms.lead_in.readLeadInFromInMemData
    %
    %   Design Decisions:
    %   -----------------
    %   1) Originally the lead in was specifically meant to handle
    %   only the lead in portion of the reading, and not anything
    %   related to the meta data. An array of lead in objects proved to be
    %   way too slow so instead more processing was done in this code and
    %   this class thus provides a summary of ALL lead ins, not just a
    %   single one.
    %
    %   It also became important to handle extraction of the raw meta data.
    %   
    %
    %   Lead In Structure:
    %   ------------------
    %   See the file "Lead_In_Format_Notes" in the private folder of this
    %   directory.
    
    properties (Hidden)
        first_word   %(uint32) First four bytes of each lead in, this varies
        %depending on whether you are reading the index file or the data
        %file.
        %
        %   See: populateFirstWord()
        
        toc_masks %[1 x n_segs], uint32 
        %Instructions for each segment. See the flags.
        reading_index_file
    end
    
    %FLAGS  ===============================================================
    
    properties
       d2 = '----  Output Flags ----' 
    end
    
    properties (Dependent)
        has_meta_data   %Indicates whether or not new property values have
        %been defined. %todo: find code that uses this and point to it
        new_obj_list    %Whether or not to reset the read order for objects.
        has_raw_data    %Whether or not a given segment contains raw data
        is_interleaved  %"      " contains interleaved 
        %data
        is_big_endian   %"      " contains data in big_endian format, normally
        %the data is is little_endian format
        has_raw_daqmx   %TODO: Provide section describing raw_daqmx
    end
    
    properties
        d3 = '----    Error Outputs    ----'
        error_in_lead_in = false %If true this indicates
        error_in_lead_in_reason  = ''%string
        %1) - invalid lead in
        %2) - size specification exceeds file size
        %3) - lead in is too close to end of file
        
        d4 = '----    Normal Outputs    ----'
        n_segs          %# of segments
        data_starts     %(double, 1 x n_segs) byte index in data file where 
        %reading starts
        %Call populateRawDataStarts() to set
        
        data_lengths    %(double, 1 x n_segs) byte lengths of all segments
        
        raw_meta_data   %({1 x n_segs} uint8 array), unprocessed meta data
        %for all segments
    end
    
%     properties (Constant,Hidden)
%         LEAD_IN_BYTE_LENGTH = 28;
%     end
    
    %TOC_MASK PARSING FUNCTIONS ===========================================
    methods
        function value = get.has_meta_data(obj)
            value = logical(bitget(obj.toc_masks,2));
        end
        function value = get.new_obj_list(obj)
            value = logical(bitget(obj.toc_masks,3));
        end
        function value = get.has_raw_data(obj)
            value = logical(bitget(obj.toc_masks,4));
        end
        function value = get.is_interleaved(obj)
            value = logical(bitget(obj.toc_masks,6));
        end
        function value = get.is_big_endian(obj)
            value = logical(bitget(obj.toc_masks,7));
        end
        function value = get.has_raw_daqmx(obj)
            value = logical(bitget(obj.toc_masks,8));
        end
    end
    
    methods
        function obj = lead_in(p_summary,options,fid,reading_index_file)
            %
            %   
            %   Inputs:
            %   -------
            %   options : tdms.options
            %   fid :
            %       This is an open reference to the file that is being
            %       read. This can either be the index or data file. The
            %       'reading_index_file' input specifies which it is.
            %   reading_index_file : logical
            %       If true 'fid' points to the index file. If false it
            %       points to the data file.
            %
            %   See Also:
            %   tdms.options
            
            obj.reading_index_file = reading_index_file;
            obj.populateFirstWord();
            
            if reading_index_file
                %tdms.lead_in.readLeadInFromInMemData
                proc_approach= 'memory';
                proc_reason = ...
                    'Memory approach always used when using the index file';
                obj.readLeadInFromInMemData(options,fid,true);
            else
                fseek(fid,0,1);
                eof_position = ftell(fid);
                fseek(fid,0,-1);
                
                if options.meta__data_in_mem_rule == 0
                    %Never do from memory
                    proc_approach = 'data file';
                    proc_reason = ...
                        'User option ''meta__data_in_mem_rule'' forbids using in memory approach';
                    obj.readLeadInFromDataFile(eof_position,options,fid);
                elseif options.meta__data_in_mem_rule == 1
                    %Do in memory based on size
                    n_MB_data = eof_position/1e6;
                    if n_MB_data < options.meta__max_MB_process_data_in_mem
                        proc_approach= 'memory';
                        proc_reason = sprintf(['Data size: %0.2f (MB) was less than the cutoff ' ...
                            'of %0.2f as specified by the option ''meta__max_MB_process_data_in_mem'''],...
                            n_MB_data,options.meta__max_MB_process_data_in_mem);
                        obj.readLeadInFromInMemData(options,fid,false);
                    else
                        proc_approach = 'data file';
                        proc_reason = sprintf(['Data size: %0.2f (MB) was greater than the cutoff ' ...
                            'of %0.2f as specified by the option ''meta__max_MB_process_data_in_mem'''],...
                            n_MB_data,options.meta__max_MB_process_data_in_mem);
                        obj.readLeadInFromDataFile(eof_position,options,fid);
                    end
                else
                    %Always from memory
                    proc_approach = 'memory';
                    proc_reason = ...
                        'User option ''meta__data_in_mem_rule'' specifies to always use the memory approach';
                    obj.readLeadInFromInMemData(options,fid);
                end
                
                
            end
            
            p_summary.lead_in_processing_approach = proc_approach;
            p_summary.lead_in_processing_approach_reason = proc_reason;
            
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
            %Segment 1 - 28*1 + 0                + meta(1)
            %Segment 2 - 28*2 + seg_lengths(1)   + meta(2)
            %Segment 3 - 28*3 + seg_lengths(1:2) + meta(3)
            
            seg_lengths_shifted = [0 seg_lengths(1:end-1)];
            obj.data_starts = cumsum(28 + seg_lengths_shifted) + meta_lengths;
            
        end
        function populateFirstWord(obj)
            %
            %   Rather than read all letters one at a time, we read the
            %   full set of characters and do a comparison to the value
            %   calculated here.

            if obj.reading_index_file
                obj.first_word = typecast(uint8('TDSh'),'uint32');
            else
                obj.first_word = typecast(uint8('TDSm'),'uint32');
            end
        end
    end
end
