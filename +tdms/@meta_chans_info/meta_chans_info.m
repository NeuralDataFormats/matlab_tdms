classdef meta_chans_info < handle
    %
    %   Class:
    %   tdms.meta_chans_info
    
    properties
        options
        
        %[1 x n_channels_allocated], double
        n_objects = 0
        n_objects_allocated
        
        %[1 x n_channels_allocated], double
        n_data_points
        
        %[1 x n_channels_allocated], tdms.meta_chan_info
        channels
        
        %{1 x n_channels_allocated}, cellstr
        names
        
        has_raw_data
    end
    
    methods
        function obj = meta_chans_info(options)
            obj.options = options;
            
            n = options.n_objects_guess;
            obj.channels = tdms.meta_chan_info.initialize(options);
            obj.n_objects_allocated = length(obj.channels);
            obj.names = cell(1,n);
            obj.has_raw_data = false(1,n);
        end
        function chan_object = getObject(obj,object_name)
            obj_I = find(strcmp(obj.names(1:obj.n_objects),object_name),1);
            if isempty(obj_I)
                obj.n_objects = obj.n_objects + 1;
                if obj.n_objects > obj.n_objects_allocated
                    n_objs_add = obj.options.n_objects_guess;
                    obj.channels = obj.channels.grow(obj.channels,obj.options);
                    obj.names = [obj.names cell(1,n_objs_add)];
                    obj.has_raw_data = [obj.has_raw_data false(1,n_objs_add)];
                    obj.n_objects_allocated = length(obj.names);
                end
                obj_I = obj.n_objects;
                obj.names{obj_I} = object_name; 
                obj.channels(obj_I).name = object_name;
            end
            chan_object = obj.channels(obj_I);
        end
        function populateDataReadInfo(obj,cur_seg)
            %
            %   Inputs
            %   ------
            %   cur_seg : 
            %
            active_chans = obj.channels(cur_seg.obj_order);
            chunk_byte_offset = 0;
            %Increment the number of data points
            for i = 1:length(active_chans)
                chan = active_chans(i);
                chunk_byte_offset = chan.updateChunkInfo(cur_seg,chunk_byte_offset);
            end
        end
    end
end

