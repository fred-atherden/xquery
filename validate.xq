(: In order for this query to functino you have to installed the schematron module:
'repo:install('https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar')'
:)

import module namespace schematron = "http://github.com/Schematron/schematron-basex";

let $xml := doc('/Users/fredatherden/desktop/elife51101.xml')

let $sch := schematron:compile(doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/pre-JATS-schematron.sch'))

let $svrl := schematron:validate($xml, $sch)

let $report-1 := <report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:file="java.io.File" xmlns:java="http://www.java.com/">{$svrl//(*:failed-assert|*:successful-report)}</report>

let $report-2 := copy $copy := $report-1
modify(
  for $x in $copy//*:failed-assert[@id="gen-country-test"]
  return delete node $x,
  
  for $y in $copy//(*:failed-assert|*:successful-report)
  return delete node $y/@test
)
return $copy

return $report-2



