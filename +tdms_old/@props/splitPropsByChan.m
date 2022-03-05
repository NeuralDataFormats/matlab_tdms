function splitPropsByChan(obj,prop_names_all,prop_vals_all,prop_chan_ids,nChans)
%
%   Do in constructor and then save to props
%
%OPTIONS
%UTC_DIFF

names  = cell(1,nChans);
values = cell(1,nChans);

%JAH TODO: Add on length error check ...

%prop_names_all,prop_vals_all,prop_chan_ids
[uChan,uChanCA] = unique2(prop_chan_ids);
for iChan = 1:length(uChan)
    [uProps,uPropsCA] = unique2(prop_names_all(uChanCA{iChan}));
    names{iChan}  = uProps;
    values{iChan} = prop_vals_all(uChanCA{iChan}(cellfun(@getLast,uPropsCA)));
end

obj.names  = names;
obj.values = values;

end

function last_val = getLast(ca)
   last_val = ca(end);
end