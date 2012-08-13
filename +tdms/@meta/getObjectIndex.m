function obj_index = getObjectIndex(obj,cur_obj_name)
%
%   This function finds the requested object in the object index list
%   
%

%POPULATE ALL OBJECT LIST
%----------------------------------------
obj_index = find(strcmp(obj.obj_names(1:obj.n_objs),cur_obj_name),1);
if isempty(obj_index)
    obj_index = obj.n_objs + 1;
    if obj_index > obj.n_objs_allocated
        obj.n_objs_allocated = obj.n_objs_allocated + obj.opt_OBJ_GROWTH_RATE;
        
        %What to do here ????
        %----------------------------------------------------
        obj.obj_names = [obj.obj_names cell(1,obj.opt_OBJ_GROWTH_RATE)];
        
%         rawDataInfo      = [rawDataInfo      ...
%             initRawInfoStruct(MAX_NUM_PROPS,MAX_NUM_OBJECTS)]; %#ok<AGROW>
%         numberDataPoints = [numberDataPoints zeros(1,MAX_NUM_OBJECTS)]; %#ok<AGROW>
%         objectHasRawData = [objectHasRawData false(1,MAX_NUM_OBJECTS)];  %#ok<AGROW>
    end
    obj.n_objs = obj_index;
    obj.obj_names{obj_index} = cur_obj_name;
end