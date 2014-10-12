classdef final_id_info < handle
    %
    %   Class: 
    %   tdms.meta.final_id_info
    %
    %   Created by:
    %       tdms.meta.readMeta
    
    properties
        parent %Class: tdms.meta
    end
    
    properties
        
        
        raw_id_to_final_id_map
        %give a raw id (as index)
        %get a final id (as value)
        
    end
    
    properties
        d2 = '----   Unique object specification mapping info ----'
        %NOTE: With these three properties, we can examine segment
        %specifications that all belong to the same object
        %
        %   Also, very importantly, earlier indices are from earlier
        %   segments than the segments specified in later indices. This is
        %   due to the stable sorting nature used by Matlab.
        
        final_to_raw_id_map %This is a vector that can be
        %used to grab a set of raw ids that all belong 
        %
        %   index: Interpretation needs indices below
        %   value: raw id By the way this is constructed, it will
        %   also yield the index into any property that is concatenated
        %   by raw_meta.unique_segment_info
        
        
        %These two vectors index into 'final_to_raw_id_map'.
        %All object specifications for the first final object are:
        %
        %   final_to_raw_id_map(...
        %               I_start__raw_obj_ids(1):I_end__raw_obj_ids(1))
        I_start__raw_obj_ids
        I_end__raw_obj_ids
    end
    
    properties
        d3 = '----- Final Object Properties -----'
        n_unique_objs
        unique_obj_names %All unique object names with unicode 
        %encoding properly handled
        data_types
        default_byte_size
        haw_raw_data
    end
    
    methods
        function obj = final_id_info(meta_obj)
            %
            %   obj = tdms.meta.final_id_info(meta_obj)
            %
            
            obj.parent = meta_obj;
            
            %tdms.meta.final_id_info.initMetaFinalIDInfo
            obj.initMetaFinalIDInfo();
        end
    end
    
end

