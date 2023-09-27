(: In order for this query to function you have to installed the schematron module for BaseX:
'repo:install('https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar')'
:)

import module namespace schematron = "http://github.com/Schematron/schematron-basex";

let $path := '/Users/fredatherden/downloads/215432.xml'
let $src := '/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/'
let $xml := doc($path)
let $filename := tokenize($path,'/')[last()]
let $folder := substring-before($path,$filename)
let $report-path := ($folder||substring-before($filename,'.xml')||'-report.xml')
let $html-path := ($folder||substring-before($filename,'.xml')||'-report.html')

let $schema := doc($src||'pre-JATS-schematron.sch')
let $external-variables := distinct-values(
                      for $x in $schema//*[@test[contains(.,'document(')]]
                      let $variable := substring-before(substring-after($x/@test,'document($'),')')
                      return $variable
                    )
let $schema2 := copy $copy := $schema
                modify(
                  for $x in $copy//*:let[@name=$external-variables]
                  return replace value of node $x/@value with concat("'",$src,replace($x/@value/string(),"'",''),"'")
                )
                return $copy
let $sch := schematron:compile($schema2)
let $svrl := schematron:validate($xml, $sch)

let $report-1 := <report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:dc="http://purl.org/dc/terms/" xmlns:e="https://elifesciences.org/namespace" xmlns:file="java.io.File" xmlns:java="http://www.java.com/">{$svrl//(*:failed-assert|*:successful-report)}</report>

let $report-2 := copy $copy := $report-1
modify(  
  for $y in $copy//(*:failed-assert|*:successful-report)
  return delete node $y/@test
)
return $copy

let $html := 
<html>
    <head></head>
    <body>
        <div style="background-color:CDFCFF;border-style: outset;padding:10px">
            <h3>{('File '||substring-after($path,'/Users/fredatherden/downloads/'))} </h3>
            <h3 style="text-align:center">Pre Schematron Validation</h3>
            <table border="2" style="background-color: white; border-collapse: collapse;width:100%">
                <thead>
                    <tr>
                        <th style="width:5%;text-align:left">Path</th>
                        <th style="width:5%;text-align:left">Type</th>
                        <th style="width:5%;text-align:left">Message</th>
                    </tr>
                </thead>
                <tbody type="schematron">{
                  for $x in $report-2//(*:successful-report|*:failed-assert)
                  let $role := $x/@role/string()
                  let $path := $x/@location/string()
                  let $message := if ($x/@see) then (data($x)||' '||$x/@see) else (data($x))
                  order by $role
                  return 
                  <tr class="{$role}">
                        <td>{$path}</td>
                        <td>{$role}</td>
                        <td>{$message}</td>
                    </tr>
                }</tbody>
            </table>
         </div>
    </body>
</html>


return (
  file:write($report-path,$report-2),
  file:write($html-path,$html)
)