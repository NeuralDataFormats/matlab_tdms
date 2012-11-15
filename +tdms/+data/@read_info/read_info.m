classdef read_info < handle
    %
    %   The goal of this class to provide a very straightfoward set of
    %   information that makes it possible to read the raw data from the
    %   file. Different readers may have need to do additional work in
    %   order to read the data as desired.
    %
    %
    %   NOTE: This class may change as the readers are written and it
    %   is determined that a better base set of information is needed.
    %   
    %   TODO: Still need to handle interleaved reads :/
    %
    %   DESIGN DECISION: Do I want to provide information about 
    %   the total # of data points for each object?
    %   - could do an accumarray on the obj_id ...
    
    properties
       parent
       
       %Each of these specifies a set of bytes to read of raw data
       obj_id      %final id
       byte_start  %where to start reading
       n_values    %
       n_bytes     %NOTE: This may not be implicit when reading a string, 
            %i.e. we may know we need to read 10 strings, but we don't know
            %how many bytes each string occupies. That information is
            %contained at the start of the data. See string reading code
            %for more info.
    end
    
    methods
        function obj = read_info(meta_obj)
           obj.parent = meta_obj;
           
           %tdms.data.read_info.getReadInstructions
           getReadInstructions(obj)
        end
    end
    
end

