
function reset!()
    for m in methods(reset_list!)
        length(m.sig.parameters)!=2 && continue
        typeOfType=m.sig.parameters[2]
        !(typeof(typeOfType)<: Type) && continue
        reset_list!(typeOfType.parameters[1])
    end
end