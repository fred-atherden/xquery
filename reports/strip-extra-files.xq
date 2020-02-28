let $pre-folder := '/Users/fredatherden/Desktop/pre-edit'
let $pub-folder := '/Users/fredatherden/Desktop/pub-check'
let $pre-files := for $x in file:list($pre-folder, true(), '*.xml') return substring-before(substring-after($x,'elife-'),'.xml')
let $pub-files := file:list($pub-folder, true(), '*.zip')

let $list := <list>{
for $zip in $pub-files
let $id := substring-before(substring-after($zip,'elife-'),'-vor')
let $version := substring-before(substring-after($zip,'-vor-r'),'.zip')
return 
if ($id = $pre-files) then <item id="{$id}" version="{$version}">{$zip}</item>
else ()
}</list>

let $latest := 
for $item in $list//*:item
let $id := $item/@id
let $version := $item/@id
return if ($item/following-sibling::*:item[(@id=$id) and (number(@version) gt number($item/@version))]) then ()
else $item/data()

for $z in $pub-files
return 
if ($z=$latest) then ()
else (file:delete($pub-folder||'/'||$z))
