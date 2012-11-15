classdef fixed < handle
    %
    %   In order to optimize the speed writing the tdms file there are two
    %   optimizations that occur that need to be "corrected" for reading.
    %   
    %   1) During writing, if a property is set for an object, the object
    %   specification can specify that it should use the previous
    %   information given regarding how to read raw data rather than
    %   specify that information is well. This corresponds to
    %   raw_obj__idx_len = 0. This class respecifies this information,
    %   specifically the # of bytes and # of values to read for each
    %   object. In addition, the # of bytes was previously only specified
    %   for strings, where the the # of values doesn't also specify the #
    %   of bytes. For easier access we populate # of bytes for all data
    %   types as this will be needed later on for processing read
    %   instrutions and is a simple indexing step.
    %
    %   2) During writing, each segment does not specify the raw data that
    %   should be read in that segment. Instead it is assumed that the same
    %   read specifications that existed in the previous segment are valid
    %   for the current segment. Three things however may change:
    %       1) Channels may be added, but the other channels are assumed to
    %          stay the same.
    %       2) The read specifications for an object may change. Its order
    %          in the write cycle however stays the same.
    %       3) A new object list may be indicated, in which case no prior
    %          channel read specifications are valid.
    %   NOTE: The data write order is based on the order of specification
    %   of the objects. In this case that means that an object with a lower
    %   raw_obj_id will always be written in a segment before one with a
    %   higher id.
    %
    %
    %   METHODS
    %   ===================================================================
    %   tdms.meta.fixed.createFinalIDInfo - NOTE: Might move into meta and
    %       pass into this constructor ..., never have as properties
    %   tdms.meta.fixed.fixNInfo          - 
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
        
        %.fixNInfo()
        %-----------------------------------------------------------
        %length is one for each raw object
        %objects are fixed in that they don't rely on previous values
        n_bytes_per_read__fixed
        n_values_per_read__fixed
        
        %.getDataOrderEachSegment()
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
                        
            fixNInfo(obj)
            
            %tdms.meta.fixed.getDataOrderEachSegment
            getDataOrderEachSegment(obj)
        end
      
    end
    
end

