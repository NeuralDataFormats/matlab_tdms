classdef lead_in < handle
    %
    %   METHODS
    %   ===============================
    %   tdms.lead_in.getFirstWord
    %   tdms.lead_in.init_obj
    %   tdms.lead_in.readLeadInFromIndexFile
    %   
    %   DESIGN DECISIONS
    %   ===================================================================
    %   1) Originally the lead in was specifically meant to handle
    %   only the lead in portion of the reading, and not anything 
    %   related to the meta data. An array of lead in objects proved to be
    %   way too slow so instead more processing was done in this code and
    %   this class thus provides a summary of ALL lead ins, not just a
    %   single one.
    
    %INPUTS TO CLASS ======================================================
    properties (Hidden)
        
        fid                 %Matlab file id reference to open file
        
        file_open  = false  %Boolean to know if file is still open
                    %Could check "fid" but this might not belong to
                    %the class anymore
        is_index_only       %indicates that the filename passed in was the index file
    end
    
    properties
       filepath_input %Filepath of TDMS file or index specified by user
       reading_index_file  %True when reading from index file, false 
        %indicates we are reading from the data file.
        
       index_vs_data_reason %Property that briefly describes in text reason
       %for reading meta data from index file or full data file
    end
    
    properties (Hidden)
        options_obj         %Class: tdms.lead_in
        first_word          %First four bytes of each lead in, this varies 
        %depending on whether you are reading the index file or the data
        %file.
        
        toc_masks       %instructions for each segment
    end
 
    properties (Dependent)
        %FLAGS
        %------------------------------------------------------------------
        has_meta_data
        new_obj_list    %Whether or not to reset the read order for objects
        has_raw_data    
        is_interleaved  %
        is_big_endian   
        has_raw_daqmx   %TODO: Provide section describing raw_daqmx
    end
    
    properties
        n_segs
        data_starts     %(double, row vector) byte index in data file where reading starts
        data_lengths    %(double, row vector) byte lengths of all segments

        meta_data       %cell array of meta data for all segments
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
        function obj = lead_in(meta_obj)
            obj.options_obj        = meta_obj.options_obj;
            obj.fid                = meta_obj.fid;
            obj.reading_index_file = meta_obj.reading_index_file;
            
            populateFirstWord(obj)
            
            if obj.reading_index_file
                %tdms.lead_in.readLeadInFromIndexFile
                readLeadInFromIndexFile(obj)
            else
                readLeadInFromDataFile(obj)
            end

            checkTocMask(obj)
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
        function populateFirstWord(obj)
            if obj.reading_index_file
                obj.first_word = typecast(uint8('TDSh'),'uint32');
            else
                obj.first_word = typecast(uint8('TDSm'),'uint32');
            end
        end
    end
    
end

