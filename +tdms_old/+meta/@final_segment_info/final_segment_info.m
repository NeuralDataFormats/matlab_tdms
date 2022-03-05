classdef final_segment_info
    %
    %   Class:
    %   tdms.meta.final_segment_info
    %
    %   See Also:
    %   tdms.meta.initMetaObject 
    %
    %   Note: Currently this is constructed in:
    %   tdms.meta.initMetaObject
    %   Although we might move it to a static method of this class.
    
    properties
        seg_id %scalar
        %   Which segment this object corresponds to. The array of objects
        %   will be in order but may have values missing if the segment
        %   does not contain raw data.
        read_order %array
        %   An array of final ids
        first_byte_pointer %number
        %   First byte in the data file for this segment
        is_interleaved %logical
        %   Whether or not the segment is interleaved
        n_values_per_read %array
        %   For each channel in the reader order, how many values from
        %   that channel are meant to be read. This should not contain
        %   any zeros.
        n_bytes_per_read  %array
        %   For each channel, the # of bytes that a read occupies.
        n_chunks
    end
    
    methods (Static)
        %tdms.meta.final_segment_info.initializeObjects
        objs = initializeObjects(obj)
    end
    
end

