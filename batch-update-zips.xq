declare namespace xlink="http://www.w3.org/1999/xlink";
(: Place all zips in a folder. :)
let $root := '/Users/fredatherden/Desktop/sh-test/'
(: Changed zips will be placed in output folder within the folder above :)
let $output-dir := ($root||'output/')
let $files := file:list($root)[ends-with(.,'.zip')]
for $file in $files
let $zip := file:read-binary($root||$file)
let $zip-entries :=  archive:entries($zip)
let $text-xml := for $entry in $zip-entries[ends-with(., '.xml') and starts-with(.,'elife-')]
                 return archive:extract-text($zip, $entry)
let $xml := fn:parse-xml($text-xml)
let $id := $xml//*:article-id[@pub-id-type="publisher-id"]
let $xml-filename := ('elife-'||$id||'.xml')
let $temp-dir := ($root||'temp/')
(: Make changes to the XML :)
let $new-xml := copy $copy := $xml
modify(
  for $x in $copy//*:ext-link[contains(@xlink:href,'softwareheritage') and ends-with(@xlink:href,'/')]
  return replace value of node $x/@xlink:href with replace($x/@xlink:href,'/$','')
)
return $copy

return (
  if (file:exists($output-dir)) then () else file:create-dir($output-dir),
  file:create-dir($temp-dir),
  archive:extract-to($temp-dir,$zip),
  file:write(($temp-dir||$xml-filename),$new-xml, map{
                  'indent':'no',
                  'omit-xml-declaration':'no',
                  'doctype-system':'JATS-archivearticle1.dtd',
                  'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN'}),
  let $new-zip := archive:create-from($temp-dir)
  return file:write-binary($output-dir||$file,$new-zip),
  file:delete($temp-dir,true())
)