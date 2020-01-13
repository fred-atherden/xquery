(: In order for this query to functino you have to installed the schematron module:
'repo:install('https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar')'
:)
import module namespace schematron = "http://github.com/Schematron/schematron-basex";

(: Compile schematron - need to account for gen-country-test which basex is unable to resolve :)
let $s := doc('/Users/fredatherden/Documents/github/elife-JATS-schematron/src/pre-JATS-schematron.sch')
let $s2 := copy $copy:=$s
modify(
  for $x in $copy//*:assert[@id='gen-country-test'] 
  return delete node $x
)
return $copy
let $sch := schematron:compile($s2)

(: Folder containing eLife zips taken from AWS bucket 'elife-production-processes' :)
let $folder := '/Users/fredatherden/Desktop/test-folder'
let $zips := file:list($folder, true(), '*.zip')

let $report := 
<report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:java="http://www.java.com/">{
  for $z in $zips
  let $zip := ($folder||'/'||$z)
  let $archive := file:read-binary($zip)
  let $zip-entries :=  archive:entries($archive)
  let $xml := for $entry in $zip-entries[ends-with(., '.xml')]
              return archive:extract-text($archive, $entry)
  let $article := fn:parse-xml($xml)[descendant::*:article]
  let $svrl := schematron:validate($article, $sch)
  return 
  <item name="{$z}" valid="{if ($svrl//(*:failed-assert[@role="error"]|*:successful-report[@role="error"])) then 'no' else 'yes'}">{$svrl//(*:failed-assert|*:successful-report)}</item>
}</report>

return (
  file:write(($folder||'/'||'report.xml'),$report),
  'Invalid files:',
  $report//*:item[@valid="no"]/@name/string()
)