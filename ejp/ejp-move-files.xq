let $root := '/Users/fredatherden/Documents/ejp-xml/new/'
let $folders := file:list($root)[.!='.DS_Store']
for $folder in $folders
let $files := file:list($root||$folder)
for $file in $files
let $source := ($root||$folder||$file)
return 
if ($file="go.xml") then file:delete($source)
else file:move($source,($root||$file))