function names_out = fixNames(names_in)

    names_out = cellfun(@helper_fixNames,names_in,'un',0);
    
end

function name_out = helper_fixNames(name_in)
    name_out = native2unicode(uint8(name_in),'UTF-8');
end