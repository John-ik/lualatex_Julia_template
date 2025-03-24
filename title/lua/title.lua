
titlePageInfo={
    departmentNum="unset",
    teacherDegree="unset",
    teacherName="unset",
    workType="unset",
    workName="unset",
    courseName="unset",
    workAuthor="unset",
    workAuthorGroup="unset",

}
print("titlePageInfo: ",titlePageInfo)
for k,v in pairs(titlePageInfo) do
    titlePageInfo[k]='\\textbackslash '..k
    define_latex_command(k,function (it)
        titlePageInfo[k]=it
    end)
    local getter="get"..string.upper(string.sub(k,1,1))..string.sub(k,2)
    print("k:",k," name:",getter)
    define_latex_command(getter,function ()
        tex.print(titlePageInfo[k])
    end)
end



local template = "&"..
"\\underoverline[4cm]{\\vphantom{\\getWorkAuthor}\\hfill\\digdate\\today}{\\phantom{P}} &"..
"\\underoverline[6cm]{%s}{\\phantom{P}} \\\\"

define_latex_command("printSignName", function(authors)
    
    for i, author in ipairs(string.split(authors, ',')) do
        tex.sprint(string.format(i > 1 and "&" .. template or template, author))
    end
end)