classdef lead_in < handle
    %
    %   METHODS
    %   ===============================
    %   tdms.lead_in.getFirstWord
    %   tdms.lead_in.init_obj
    %   tdms.lead_in.readLeadInFromIndexFile
    %   
    %   DESIGN DECISIONS
    %   =================================================
    %   1) Originally the lead in was specifically meant to handle
    %   only the lead in portion of the reading, and not anything 
    %   related to the meta data. An array of lead in objects proved to be
    %   way too slow so instead more processing was done in this code and
    %   this class thus provides a summary of ALL lead ins, not just a
    %   single one.
    %
    %   TODO
    %   =============================================================
    %   1) Only reading from .tdms_index files is currently supported
    %
    
    %INPUTS TO CLASS ==========================================
    properties (Hidden)
        fid
        reading_index_file
        options_obj
        first_word
        
        toc_masks       %instructions for each segment
    end
    
    properties (Dependent)
        %FLAGS
        %--------------------------------
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
            
            getFirstWord(obj)
            
            if obj.reading_index_file
                readLeadInFromIndexFile(obj)
            else
                error('Unhandled case')
            end

            checkTocMask(obj)
        end
        function checkTocMask(obj)
           if any(obj.is_big_endian)
               
           end
           if any(obj.has_raw_daqmx)
               
           end
        end
        function getFirstWord(obj)
            if obj.reading_index_file
                obj.first_word = typecast(uint8('TDSh'),'uint32');
            else
                obj.first_word = typecast(uint8('TDSm'),'uint32');
            end
        end
    end
    
end

