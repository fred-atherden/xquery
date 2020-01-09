let $db := 'biorxiv'
let $dir := '/Users/fredatherden/Documents/biorxiv-xml/xml/'

for $file in file:list($dir)
let $xml := doc($dir||$file)
return db:replace($db,$file,$xml)