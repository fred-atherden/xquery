let $sch := doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/schematron.sch')


  for $x in $sch//(*:assert|*:report)
  let $prefix := ("**"||upper-case(substring($x/@role,1,1))||substring($x/@role,2)||"**: _")
  let $message := normalize-space(string-join(for $y in $x/(*|text()) return if ($y/local-name()='value-of') then ("XXXXXX") else if ($y/local-name()='name') then ("XXXXXX") else $y))
  let $context := $x/parent::*:rule/@context
  let $wiki := if ($x/@see) then $x/@see/string()
  else ()
  let $tests := ('=HYPERLINK("https://github.com/elifesciences/eLife-JATS-schematron/tree/master/test/tests/gen/'||$x/parent::*:rule/@id||'/'||$x/@id||'", "'||$x/@id||'")')
  
  return 
  ($tests||'	'||$context/string()||'	'||concat($prefix,$message,'_')||'	'||$wiki)