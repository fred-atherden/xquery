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
    where not($x//*:ext-link[matches(lower-case(@*:href),'^https?://identifiers.org/RRID|https?://scicrunch.org/resolver/')])
    return <item id="{$id}" doi="{$doi}" pub-year="{$pub-year}">{$b}</item>
    }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
for $year in distinct-values($list//*:item/@pub-year)
  let $items := $list//*:item[@pub-year = $year]
  let $no-rrids := count(
                  for $x in $items
                  let $doi := lower-case($x/@doi)
                  return
                  if ($event-data/*[*:subj/*:title[contains(lower-case(.),'scibot')] and *:obj/*:pid[contains(.,$doi)]]) 
                    then ()
                  else $x)
  return $year||'	'||count($items)||'	'||$no-rrids