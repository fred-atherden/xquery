declare variable $outputDir := '/Users/fredatherden/Desktop/ejp.xml';
declare variable $numbers := (12,13,14,15,16,17,18,19,20,21);
declare function local:get-sub-type($version-number){
  if ($version-number='0') then 'full'
  else 'revised'
};


let $list := <list>{
  for $number in $numbers
  let $year := ('20'||string($number))
  let $db := 'ejp-'||$year
    for $x in collection($db)//*:xml//*:version[not(*:manuscript-type[starts-with(.,'Initial')])]
    let $ms-no := $x/*:manuscript-number/data()
    let $ms-type := lower-case($x/*:manuscript-type)
    (: Initial subs have IS in their MS no, so this excludes them :)
    where not(contains($ms-no,'xPub') and not(contains($ms-no,'IS')))
    let $no := substring(tokenize($ms-no,'-')[matches(.,'\d{5}')],1,5)
    let $sub-type := local:get-sub-type($x/*:version-number)
    return <item id="{$no}" ms-no="{$ms-no}" ms-type="{$ms-type}" sub-type="{$sub-type}" base-uri="{$x/base-uri()}"/>
}</list>

return file:write($outputDir,$list)
