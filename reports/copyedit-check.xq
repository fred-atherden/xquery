import module namespace schematron = "http://github.com/Schematron/schematron-basex";


let $src := '/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/'
let $schema := doc($src||'copy-edit.sch')

let $schema2 := copy $copy := $schema
                modify(
                  for $x in $copy//*:let[@name=("list")]
                  return replace value of node $x/@value with concat("document('",$src,substring-after($x/@value,"document('"))
                )
                return $copy
let $sch := schematron:compile($schema2)

(: Folder containing eLife zips taken from AWS bucket 'elife-production-processes' :)
let $pre-folder := '/Users/fredatherden/Desktop/pre-edit'
let $pre-files := file:list($pre-folder, true(), '*.xml')

let $pre-report := 
<report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:java="http://www.java.com/" xmlns:file="java.io.File">{
  for $z in $pre-files
  let $article := doc($pre-folder||'/'||$z)
  let $svrl := schematron:validate($article, $sch)
  return 
  <item name="{$z}" valid="{if ($svrl//(*:failed-assert[@role="error"]|*:successful-report[@role="error"])) then 'no' else 'yes'}">{$svrl//(*:failed-assert|*:successful-report)}</item>
}</report>

return $pre-report