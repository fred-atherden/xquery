(: Download files from s3://elife-ejp-ftp-db-xml-dump and extract (keeping inside folder) :)
let $list := 
<list>{
  let $root := '/Users/fredatherden/Documents/ejp-xml/new/'
  let $folders := file:list($root)[.!='.DS_Store']
  for $folder in $folders
  let $substring := substring-before(substring-after($folder,'ejp_eLife_'),'/')
  let $dateTime-number := replace($substring,'_','')
  let $files := file:list($root||$folder)
  for $file in $files 
  let $id := substring-before(tokenize($file,'-')[last()],'.xml')
  return <item id="{$id}" number="{$dateTime-number}">{($root||$folder||$file)}</item>
}</list>

let $ids := distinct-values($list//*:item/@id[matches(.,'\d{5}')])

for $id in $ids
let $items := $list//*:item[@id=$id]
let $max := max(for $item in $items return number($item/@number))
let $min-items := $items[@number!=$max]
for $item in $min-items
return file:delete($item/text())