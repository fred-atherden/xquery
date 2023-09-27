declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace elife = "elife";
declare variable $sch := doc("/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/schematron.sch");

declare function local:schematron-to-xquery(
  $assert-or-report as node(),
  $rule as node()
){
  let $context := ("("||$rule/@context||")")
  let $test := ("["||$assert-or-report/@test||"]")
  let $message := 
  ("("||
    string-join(
    for $y in $assert-or-report/(text()|*)
    return
    switch ($y/local-name())
      case 'name' return '$x/name()'
      case 'value-of' return ('$x/'||$y/@select)
      default return ("'"||replace($y,"'",'')||"'")
  ,'||')||
  ")")
  
  return 
  switch ($assert-or-report/local-name())
    case ("assert") return ("for $x in $xml//"||$context||" return if (not($x"||$test||")) then "||$message)
    case ("report") return ("for $x in $xml//"||$context||" return if ($x"||$test||") then "||$message)
    default return error(xs:QName("elife:error"),'error')
  
};

string-join(
for $x in $sch//(*:assert|*:report)
return local:schematron-to-xquery($x,$x/parent::*:rule)
,",&#xa;")