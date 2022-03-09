(: In order for this query to function you have to installed the schematron module:
'repo:install('https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar')'
:)
import module namespace schematron = "http://github.com/Schematron/schematron-basex";

(: Define version of schematron used that week :)
let $commit := 'e351d70400ea304b444a35e44722ad6e0d73b37b'
(: Compile schematron :)
let $src := '/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/'
let $schema := fetch:xml('https://raw.githubusercontent.com/elifesciences/eLife-JATS-schematron/'||$commit||'/src/pre-JATS-schematron.sch')
let $schema2 := copy $copy := $schema
                modify(
                  for $x in $copy//*:let[@name=("journals","countries","publisher-locations","publishers","rors","clinical-trial-registries","credit-roles","funders")]
                  return replace value of node $x/@value with concat("'",$src,replace($x/@value/string(),"'",''),"'")
                )
                return $copy
let $sch := schematron:compile($schema2)

(: Folder containing eLife zips taken from AWS bucket 'elife-production-processes' :)
let $pre-folder := '/Users/fredatherden/Desktop/pre-edit'
let $pre-files := file:list($pre-folder, true(), '*.xml')

let $pre-report := 
<report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:java="http://www.java.com/" xmlns:file="java.io.File">{
  for $z in $pre-files
  where not(matches($z,'64041|67784|59437|67855|67077|67092|62552|61461|66601|69431|55665|58609|59437|59697|61461|61700|62552|63542|64041|64045|64134|64140|64204|65745|65897|66419|66601|66608|67092|67291|67340|67587|67784|67855|68128|70394|70591|65835|68268|64518'))
  let $article := doc($pre-folder||'/'||$z)
  let $svrl := schematron:validate($article, $sch)
  return 
  <item name="{$z}" valid="{if ($svrl//(*:failed-assert[@role="error"]|*:successful-report[@role="error"])) then 'no' else 'yes'}">{$svrl//(*:failed-assert|*:successful-report)}</item>
}</report>

return file:write(($pre-folder||'/'||'pre-report.xml'),$pre-report)