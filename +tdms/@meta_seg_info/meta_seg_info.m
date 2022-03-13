classdef meta_seg_info < handle
    %
    %   Class:
    %   tdms.meta_seg_info
    %
    %   See Also
    %   --------
    %   tdms.meta_chan_info
    
    
    properties
        index
        
        data_start_position
        
        %Do we need this?
        is_new_obj_list
        is_interleaved
        is_big_endian
        
        %[1 x n_data_objects]
        obj_order
        
        n_data_objects
        
        %[1 x n_data_objects]
        %
        %- matches object order
        n_samples_read
        n_bytes_read
        
        %
        n_chunks
        n_bytes_per_chunk
    end
    
    methods (Static)
        function objs = initialize(options)
            %
            %   objs = tdms.meta_seg_info.initialize(options)
            %
            %   Inputs
            %   ------
            %   options: tdms.options
            
            n = options.n_segs_guess;
            objs(1,n) = tdms.meta_seg_info();
            for i = 1:n
                objs(i).index = i;
            end
        end
        function objs = grow(objs,options)
            n1 = length(objs);
            n = n1 + options.n_segs_increment;
            objs(1,n) = tdms.meta_chan_info();
            for i = (n1+1):n
                objs(i).index = i;
            end
        end
    end
    
    methods
        function populateSegmentReadInfo(obj,read_order,all_channels,byte_size_raw)
            %
            %
            %   Inputs
            %   ------
            %   read_order : [1 x n_chans] double
            %       Indices of the channels that will be read.
            %   all_channels : [1 x all_chans] tdms.meta_chan_info
            %       
            %   
            %   See Also
            %   --------
            %   tdms.read_order 
            
            obj.obj_order = read_order;
            obj.n_data_objects = length(read_order);
            
            relevant_chans = all_channels(read_order);
            %tdms.meta_chan_info
            
            obj.n_samples_read = [relevant_chans.n_values_per_read];
            obj.n_bytes_read = [relevant_chans.n_bytes_per_read];
            
            total_bytes_per_chunk = sum(obj.n_bytes_read);
            n_chunks_local = byte_size_raw/total_bytes_per_chunk;
            
            obj.n_chunks = n_chunks_local;
            obj.n_bytes_per_chunk = total_bytes_per_chunk;

%             %Some error checking
%             %------------------------------------------
%             if DEBUG
%                 fprintf(2,'nChunks: %d\n',nChunks);
%                 fprintf(2,'nSamplesRead: %s\n',mat2str(n_samples_read));
%                 fprintf(2,'totalBytesPerChunk: %d\n',totalBytesPerChunk);
%                 fprintf(2,'byteSizeRaw: %d\n',byte_size_raw);
%             end
            
            if n_chunks_local ~= floor(n_chunks_local)
                %TODO: dump all info here of what's going on
                error(['The remaining data doesn''t split evently into' ...
                    ' chunks, estimated # of chunks: %d'],n_chunks_local)
            end
            
           
        end
    end
end

