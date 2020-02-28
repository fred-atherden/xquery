let $sch := doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/schematron.sch')

let $csv := 
<csv>{
  for $x in $sch//(*:assert|*:report)
  let $context := $x/parent::*:rule/@context
  return 
  <record>
  <entry>{$x/@id/string()}</entry>
  <entry>{$context/string()}</entry>
  <entry>{string-join(for $y in $x/(*|text()) return if ($y/local-name()='value-of') then ("''") else $y)}</entry>
  </record>
}</csv>

return file:write('/Users/fredatherden/Desktop/schematron.csv',$csv, map{'method':'csv'})