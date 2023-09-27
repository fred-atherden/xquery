import module namespace schematron = "http://github.com/Schematron/schematron-basex";

let $schema := doc('/Users/fredatherden/desktop/publisher-test.sch')
let $sch := schematron:compile($schema)

for $xml in collection('ijm')//*:article[descendant::*:ref-list]
let $svrl := schematron:validate($xml, $sch)

return if ($svrl//*:successful-report or $svrl//*:failed-assert) then (
  $xml/base-uri(),
  $svrl//(*:successful-report/*:text|$svrl//*:failed-assert/*:text)
)
else ()