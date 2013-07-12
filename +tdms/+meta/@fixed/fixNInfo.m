function fixNInfo(obj)
%fixNInfo
%
%   fixNInfo(obj)
%
%   Background
%   =======================================================================
%   See point 1 in class documentation header.
%
%   This function:
%   =======================================================================
%   1) Corrects n_values_per_read_final
%   2) Populates n_bytes_per_read_final for all data types, not just
%      strings
%   3) Checks that the data type of an object does not change
%   4) Ensures that all objects have a previous specification if the
%      instructions specify to use a previous specification
%   5) Populates the data type of each final object
%
%   IMPORTANT: A value of raw_meta.raw_obj__idx_len equal to zero specifies
%   that the object should use the last valid specification of the object
%   where the idx_len (index length) is non-zero, but also valid, i.e.
%   where raw_meta.raw_obj__has_raw_data is true.
%
%   Class: tdms.meta.fixed

%Object properties for quicker reference
final_ids_obj = obj.parent.final_ids;           %Class: tdms.meta.final_id
final_obj_id  = final_ids_obj.final_obj_id; 
n_unique_objs = final_ids_obj.n_unique_objs;

%For Reference
%------------------------------------------------------------------
raw_meta_obj        = obj.raw_meta;
raw_obj__idx_len    = raw_meta_obj.raw_obj__idx_len;
raw_obj__data_types = raw_meta_obj.raw_obj__data_types;

%Intermediate variables to assist processing 
%------------------------------------------------------------------
final_obj__set          = false(1,n_unique_objs); %Whether or not
%we have instructions on what type of data the object contains.

final_obj__data_type    = zeros(1,n_unique_objs);
final_obj__cur_n_values = zeros(1,n_unique_objs);
final_obj__cur_n_bytes  = zeros(1,n_unique_objs);

%Variables to populate
%------------------------------------------------------------------
%These are the output variables. We start with what they were previously.
%We then update them as we come across instructions that tell us to use the
%previous value.
n_values_per_read_fixed = raw_meta_obj.raw_obj__n_values_per_read;
n_bytes_per_read_fixed  = raw_meta_obj.raw_obj__n_bytes_per_read;


%Update these variables to handle the "previous" instruction
%==========================================================================
%NOTE: Often there are no zeros. I could write a separate case which
%only does the data type checking ...
%(Optimization, LOW PRIORITY)
for iRaw = find(raw_meta_obj.raw_obj__has_raw_data)
    cur_final_id = final_obj_id(iRaw);
    if raw_obj__idx_len(iRaw) == 0  %Use previous -------------------------
        if final_obj__set(cur_final_id)
            n_values_per_read_fixed(iRaw) = final_obj__cur_n_values(cur_final_id);
            n_bytes_per_read_fixed(iRaw)  = final_obj__cur_n_bytes(cur_final_id);
        else
            %TODO: Provide reference to some error code, improve msg
            error('Channel data info has yet to be set')
        end
    else  %Update instructions --------------------------------------------
        final_obj__cur_n_values(cur_final_id) = n_values_per_read_fixed(iRaw);
        final_obj__cur_n_bytes(cur_final_id)  = n_bytes_per_read_fixed(iRaw);
        if final_obj__set(cur_final_id)
            if final_obj__data_type(cur_final_id) ~= raw_obj__data_types(iRaw)
                %TODO: Provide reference to some error code, improve msg
                error('Data type can''t change ...')
            end
        else
            final_obj__set(cur_final_id) = true;
            final_obj__data_type(cur_final_id) = raw_obj__data_types(iRaw);
        end
    end
end

%Update bytes per read for non-string types
%--------------------------------------------------------------------------
data_types_final = final_obj__data_type(final_obj_id); %This gives us final
%data types on the same scale as the raw object specification (i.e. size is
%[1 x raw] NOT [1 x final]

update_mask      = n_bytes_per_read_fixed == 0 & n_values_per_read_fixed ~= 0;
%Update if the # of bytes per read is zero, which it will be for
%non-numeric types, as well as non-data objects, AND if we have data for
%that channel

n_bytes_by_type  = tdms.meta.getNBytesByTypeArray; %Static method call

n_bytes_per_read_fixed(update_mask) = ...
    n_bytes_by_type(data_types_final(update_mask))...  %bytes per element
    .*n_values_per_read_fixed(update_mask);            %# elements

%NOTE: # of values is set for both strings and non-string types so we
%don't need to update the property 'n_values_per_read_fixed' other than
%handling the previous instructions

%Final assignment
%--------------------------------------------------------
obj.n_bytes_per_read__fixed     = n_bytes_per_read_fixed; 
obj.n_values_per_read__fixed    = n_values_per_read_fixed;
obj.final_obj__data_type        = final_obj__data_type;


end