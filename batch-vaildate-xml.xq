(: In order for this query to functino you have to installed the schematron module:
'repo:install('https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar')'
:)
import module namespace schematron = "http://github.com/Schematron/schematron-basex";

(: Compile schematron :)
let $src := '/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/'
let $schema := fetch:xml('https://raw.githubusercontent.com/elifesciences/eLife-JATS-schematron/master/src/pre-JATS-schematron.sch')
let $schema2 := copy $copy := $schema
                modify(
                  for $x in $copy//*:let[@name=("journals","countries","publisher-locations","publishers")]
                  return replace value of node $x/@value with concat("'",$src,replace($x/@value/string(),"'",''),"'")
                )
                return $copy
let $sch := schematron:compile($schema2)

(: Folder containing eLife zips taken from AWS bucket 'elife-production-processes' :)
let $folder := '/Users/fredatherden/Desktop/test-folder'
let $files := file:list($folder, true(), '*.xml')

let $report := 
<report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:java="http://www.java.com/">{
  for $z in $files
  let $article := doc($folder||'/'||$z)
  let $svrl := schematron:validate($article, $sch)
  return 
  <item name="{$z}" valid="{if ($svrl//(*:failed-assert[@role="error"]|*:successful-report[@role="error"])) then 'no' else 'yes'}">{$svrl//(*:failed-assert|*:successful-report)}</item>
}</report>

return (
  file:write(($folder||'/'||'report.xml'),$report),
  'Invalid files:',
  $report//*:item[@valid="no"]/@name/string()
)