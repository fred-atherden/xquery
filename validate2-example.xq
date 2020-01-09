(: In order for this query to functino you have to installed the schematron module:
'repo:install('https://github.com/Schematron/schematron-basex/raw/master/dist/schematron-basex-1.2.xar')'
:)

import module namespace schematron = "http://github.com/Schematron/schematron-basex";

let $xsl := schematron:compile(doc('/Users/fredatherden/Desktop/test2.sch'))
let $dir := '/Users/fredatherden/Desktop/test2/'

for $x in collection('articles')//*:article[*:body]
let $output := xslt:transform($x,$xsl)
let $name := substring-after($x/base-uri(),'articles/')
return 
if ($output//*:failed-assert[not(contains(@location,'object-id'))]) then file:write(($dir||$name),$output)
else ()