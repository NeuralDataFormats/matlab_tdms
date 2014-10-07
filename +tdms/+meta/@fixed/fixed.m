classdef fixed < handle
    %
    %   Class: tdms.meta.fixed
    %
    %   In order to optimize speed when writing the tdms file there are two
    %   optimizations that occur that need to be corrected for or
    %   interpreted during reading.
    %   
    %   1) During writing, if a property is set for an object, the object
    %   specification can specify that it should use the previous
    %   information given regarding how to read raw data rather than
    %   specify that information again. This corresponds to
    %   raw_obj__idx_len = 0 (tdms.meta.raw). This class respecifies this
    %   information, specifically the # of bytes and # of values to read
    %   for each object. In addition, the # of bytes was previously only
    %   specified for strings. This is done by NI, since the # of bytes 
    %   for other data types is inherit to the data type -> i.e. double = 8).For 
    %   easier access we populate # of bytes for all data types as this 
    %   will be needed later on for processing
    %   read instrutions and is a simple indexing step.
    %
    %   2) During writing, each segment does not specify the raw data that
    %   should be read in that segment. Instead we have a list of channels
    %   which we are supposed to read from, and a number of samples to read
    %   from each channel for a single read pass. If we do not exceed the #
    %   of raw data samples specified for the segment, we reread everything
    %   again and again until all samples are exhausted.
    %
    %   The list itself is maintained between segments and can be added to
    %   or restarted new in any segment.
    %       Things to take into account are:
    %       1) Channels may be added, but the other channels are assumed to
    %          stay the same. The channels are added to the end of the
    %          list.
    %       2) The read specifications for an object may change. Its order
    %          in the write cycle however stays the same.
    %       3) A new object list may be indicated, in which case no prior
    %          channel read specifications are valid.
    %
    %   NOTE: The data write order is based on the order of specification
    %   of the objects. In this case that means that an object with a lower
    %   raw_obj_id will always be written in a segment before one with a
    %   higher id.
    %
    %
    %   tdms.meta.fixed.getDataOrderEachSegment - 
    
    properties (Hidden)
        parent
        raw_meta
    end
    
    properties                             
        %.fixNInfo()     
        %-----------------------------------------------------------------
        final_obj__data_type %(length = n_unique_objs) The data type of each final object. There is 
                             %only one value per final id element, i.e.
                             %goes from 1 to n_unique_objs
    end
    
    %These properties handle the "previous" value definition as well
    %as defining bytes per read for non-string types
    properties
        %.fixNInfo() - tdms.meta.fixed.fixNInfo
        %-----------------------------------------------------------
        %length is one for each raw object
        %objects are fixed in that they don't rely on previous values
        n_bytes_per_read__fixed
        n_values_per_read__fixed
    end
    
    properties
        %.getDataOrderEachSegment() - tdms.meta.fixed.getDataOrderEachSegment
        %-------------------------------------------------------
        %Specifies reads for each object with data in each segment
        %- i.e. seg_id and obj_id are paired
        %IMPORTANTLY: These are sorted by seg_id first, then obj_id
        seg_id %segment of the object
        obj_id %raw obj id, can be used for indexing into raw_obj properties
    end
    
    methods
        function obj = fixed(meta_obj)
            obj.parent   = meta_obj;
            obj.raw_meta = meta_obj.raw_meta;
            
            %tdms.meta.fixed.fixNInfo
            fixNInfo(obj)
            
            %tdms.meta.fixed.getDataOrderEachSegment
            getDataOrderEachSegment(obj)
        end
      
    end
    
end

