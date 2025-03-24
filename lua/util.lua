define_latex_command("ifmany", function(a, b, c)
    if #(string.split(a, ',')) > 1 then
        tex.print(b)
    else
        tex.print(c)
    end
end)
