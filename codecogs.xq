let $zip-location := '/Users/fredatherden/Desktop/file.docx'
let $zip-name := tokenize($zip-location,'/')[last()]
let $zip := file:read-binary($zip-location)
let $zip-entries := archive:entries($zip)
let $rels := parse-xml(for $entry in $zip-entries[ends-with(., 'document.xml.rels')]
                        return archive:extract-text($zip, $entry))
let $doc := parse-xml(for $entry in $zip-entries[ends-with(., 'document.xml')]
                        return archive:extract-text($zip, $entry))

for $x in $doc//(*:hyperlink[descendant::*:drawing]|*:drawing//*:hlinkClick)
let $id := $x/@*:id
let $link := $rels//*[@Id=$id]/@Target/string()
let $tex := replace(web:decode-url(substring-after($link,'latex=')),'#0$','')
return $link||'&#10;'||$tex||'&#10;&#10;'