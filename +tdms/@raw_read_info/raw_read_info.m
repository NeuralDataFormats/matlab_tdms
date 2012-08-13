classdef raw_read_info < handle
    %
    
    properties
       n_current_objs = 0
       chan_order     = []
       n_values_read  = []
    end
    
    methods
    
        function new_list(obj,num_new_objs)
           if num_new_objs*2 > length(obj.chan_order)
              %Create new
              obj.chan_order    = zeros(1,2*num_new_objs);
              obj.n_values_read = zeros(1,2*num_new_objs);
           else
              obj.n_current_objs   = 0;
              obj.chan_order(:)    = 0;
              obj.n_values_read(:) = 0;
           end
        end
    
    end
    
    
    
end

