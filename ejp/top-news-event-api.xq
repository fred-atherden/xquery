(: Run get-new-event-data.xq first :)
declare variable $folder := "/Users/fredatherden/Desktop/event-news-data/";

let $events := <events>{
  for $file in file:list($folder)[ends-with(.,'.xml')]
  let $xml := doc($folder||$file)
  return $xml//*:events/_
}</events>

for $x in distinct-values($events/*:_/*:obj/*:pid)
let $count := count(distinct-values($events/*:_[*:obj/*:pid=$x]/*:subj/*:pid))
order by $count descending
return substring-after(lower-case($x),'elife.')||' -  cited by '||$count||' "News" articles.'