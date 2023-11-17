declare variable $month := '2023-10';

declare function local:median($vals){
  let $values := for $x in $vals order by number($x) ascending return $x
  let $count := count($values)
  let $median-number :=  if (($count mod 2)=1) then (($count div 2)+0.5)
                         else (
                            ($count div 2),
                            (($count div 2)+1)
                         )

  let $median := if (count($median-number)=1) then (
                              for $x at $p in $values
                              where $p=$median-number
                              return $x
                                              )
                 else (sum(for $x at $p in $values
                           where $p=$median-number
                           return number($x)) div 2)

  return $median
};


let $json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'))
(: to get the excel file run Query: RP9 - Article tracking in eJP and then save as csv :)
let $csv := csv:parse(file:read-text('/Users/fredatherden/Downloads/elife-rp_query_tool_rp09__article_tracking.csv'))

let $v1-subs-to-pubs := 
  local:median(
    for $rpv1 in $json//*:manuscripts/*[not(*)]
    let $msid := substring-before($rpv1,'v')
    let $v := substring-after($rpv1,'v')
    let $timeline := $json//*:manuscripts/*[*:msid=$msid and *:version=$v]/status/timeline
    let $rpv1-event := $timeline/*[starts-with(*:date[1],$month) and matches(lower-case(*:name[1]),'reviewed preprint posted|version 1')]
    where $rpv1-event
    let $date := xs:date($rpv1-event/*:date)
    let $init-sub := $csv//*:record[entry[1]=$msid and entry[last()]='After Peer Review'][1]/entry[4]
    where $init-sub
    let $sub-date := xs:date(string-join(for $y at $p in tokenize($init-sub,'/') order by $p descending return $y,'-'))
    return ($date - $sub-date) div xs:dayTimeDuration("P1D")
  )
  
  

let $v2-subs-to-pubs := 
  local:median(
    for $rpv2 in $json//*:manuscripts/*[not(*) and not(ends-with(.,'v[13]'))]
    let $msid := substring-before($rpv2,'v')
    let $v := substring-after($rpv2,'v')
    let $timeline := $json//*:manuscripts/*[*:msid=$msid and *:version=$v]/status/timeline
    let $rpv2-event := $timeline/*[starts-with(*:date[1],$month) and matches(lower-case(*:name[1]),'version 2')]
    where $rpv2-event
    let $date := xs:date($rpv2-event/*:date)
    let $init-sub := $csv//*:record[entry[1]=$msid and entry[last()]='After Peer Review'][1]/entry[4]
    where $init-sub
    let $sub-date := xs:date(string-join(for $y at $p in tokenize($init-sub,'/') order by $p descending return $y,'-'))
    return ($date - $sub-date) div xs:dayTimeDuration("P1D")
   )
   
let $v3-subs-to-pubs := 
  local:median(
    for $rpv3 in $json//*:manuscripts/*[not(*) and not(matches(.,'v[12]$'))]
    let $msid := substring-before($rpv3,'v')
    let $v := substring-after($rpv3,'v')
    let $timeline := $json//*:manuscripts/*[*:msid=$msid and *:version=$v]/status/timeline
    let $rpv3-event := $timeline/*[starts-with(*:date[1],$month) and matches(lower-case(*:name[1]),'version 3')]
    where $rpv3-event
    let $date := xs:date($rpv3-event/*:date)
    let $init-sub := $csv//*:record[entry[1]=$msid and entry[last()]='After Peer Review'][1]/entry[4]
    where $init-sub
    let $sub-date := xs:date(string-join(for $y at $p in tokenize($init-sub,'/') order by $p descending return $y,'-'))
    return ($date - $sub-date) div xs:dayTimeDuration("P1D")
   )


return (
  'Median days from submission to RPv1: '||$v1-subs-to-pubs,
  'Median days from submission to RPv2: '||$v2-subs-to-pubs,
  'Median days from submission to RPv3: '||$v3-subs-to-pubs
)