classdef read_order < handle
    %
    %   Class:
    %   tdms.read_order
    
    properties
        %Specifies how many #s in 'order' are valid
        count
        
        %[1 x n_allocated], double
        order
        
        %n_values_per_read
    end
    
    methods
        function initialize(obj,n_new_obj_in_seg)
            obj.count = 0;
            obj.order = zeros(1,2*n_new_obj_in_seg);
            %obj.n_values_per_read = zeros(1,2*n_new_obj_in_seg);
            %NOTE: I padded this by doubling the #, we might append extra
            %channels in subsequent reads, I currently don't resize this
            %...
        end
        function update(obj,chan,lead_in)
            chan_index = chan.index;
            
            if chan.has_raw_data
                appendToList = false;
                if lead_in.kTocNewObjList
                    appendToList = true;
                else %Only append if not currently specified
                    I_objOrder = find(obj.order(1:obj.count) == chan_index,1);
                    if isempty(I_objOrder)
                        appendToList = true;
                    else
                        %obj.n_values_read(I_objOrder) = chan.n_values_per_read;
                    end
                end
                
                %NOTE: No overflow code in place yet, however we do
                %initialize with twice the # of objects specified to be
                %in a segement when a new list is created, new segments
                %might add more objects to the list
                if appendToList
                    obj.count = obj.count + 1;
                    obj.order(obj.count) = chan_index;
                    %obj.n_values_per_read(obj.count) = chan.n_values_per_read;
                end
            end
        end
        function read_order = getSegmentReadOrder(obj,chan_info_objs)
            base_obj_order = obj.order(1:obj.count);
            temp_objects = chan_info_objs(base_obj_order);
            %TODO: What about n_values == 0
            %
            %I think this is handled fine ...
            %
            %JAH 3/3/2022
            %Problems occurred when we don't have a new object list
            %but for an object currently being read we specify it doesn't
            %have raw data when it did previously
            has_data_mask = [temp_objects.has_raw_data];
            read_order = base_obj_order(has_data_mask);            
        end
    end
end

