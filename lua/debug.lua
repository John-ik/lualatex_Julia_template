local save_texprint = tex.print
function tex.print(...)
    texio.write('term and log', "DEBUG tex.print: <<",..., '>>\n')
    save_texprint(...)
end