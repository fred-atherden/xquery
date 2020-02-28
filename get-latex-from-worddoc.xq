let $file := doc('/Users/fredatherden/Desktop/document.xml')
let $rel := doc('/Users/fredatherden/Desktop/rels.xml')

for $x in $file//*:hyperlink[descendant::*:drawing]
let $id := $x/@*:id/string()
let $link := $rel//*:Relationship[@*:Id/string()=$id]/@*:Target/string()
let $latex := (substring-after(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace($link,'%2C',','),'%5C','\\'),'%5E','^'),'%3D','='),'%2B','+'),'%7B','{'),'%7D','}'),'%20',' '),'%250',''),'%2F','/'),'%5B','['),'%5D',']'),'%3B',';'),'%26','&amp;'),'%7C','|'),'https://www.codecogs.com/eqnedit.php?latex=') || '&#xa;')


return $latex