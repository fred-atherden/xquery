declare variable $folder := "/Users/fredatherden/Desktop/event-data/";

let $event-data := <xml>{
  for $file in file:list($folder)[ends-with(.,'.xml')]
  let $xml := doc($folder||$file)
  return $xml//*:events/*
}</xml>

let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[@article-type=("research-article","review-article") and *:body]
    let $doi := $x//*:article-meta/*:article-id[@pub-id-type="doi"]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return <item id="{$id}" doi="{$doi}" pub-year="{$pub-year}">{$b}</item>
    }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
for $year in distinct-values($list//*:item/@pub-year)
  let $dois := $list//*:item[@pub-year=$year]/@doi
  let $doi-regex := string-join(for $x in $dois return lower-case($x),'|')
  let $hyp-count := count(distinct-values(
              for $x in $event-data/*[*:subj/*:title[contains(lower-case(.),'scibot')] and *:obj/*:pid[matches(.,$doi-regex)]]
              return $x/*:obj/*:pid))
  return ($year||'	'||count($dois)||'	'||$hyp-count)