declare variable $id := 71420;
declare variable $folder := "/Users/fredatherden/Desktop/"||$id||"/";

let $events := <events>{
  for $file in file:list($folder)[ends-with(.,'.xml')]
  let $xml := doc($folder||$file)
  return $xml//*:events/*
}</events>

let $wikis := distinct-values($events/*[*:source__id="wikipedia"]/*:subj/*:pid)
let $news := distinct-values($events/*[*:source__id="newsfeed"]/*:subj/*:pid)
let $blogs := distinct-values($events/*[*:source__id="wordpressdotcom"]/*:subj/*:pid)
let $tweets := for $x in $events/*[*:source__id="twitter"]/*:subj 
               where ($x/*:original-tweet-author[@type="null"]) 
               return $x
let $retweets := for $x in $events/*[*:source__id="twitter"]/*:subj 
                 where ($x/*:original-tweet-author[not(@type="null")]) 
                 return $x
let $reddits := $events/*[*:source__id="reddit"]/*:subj/*:pid
let $faculty-opinions := $events/*[*:source__id="facultyopinions"]/*:subj/*:pid

let $strings := (
  if (exists($wikis)) then "Cited in "||count($wikis)||" wikipedia articles&#10;"||string-join($wikis,'&#10;'),
  if (exists($news)) then count($news)||" News articles&#10;"||string-join($news,'&#10;'),
  if (exists($blogs)) then count($blogs)||" Blogs (WordPress)&#10;"||string-join($blogs,"&#10;"),
  if (exists($tweets)) then count($tweets)||" Tweets",
  if (exists($retweets)) then count($retweets)||" Tweets",
  if (exists($reddits)) then count($reddits)||" Reddit posts&#10;"||string-join($reddits,'&#10;'),
  if (exists($faculty-opinions)) then count($faculty-opinions)||" Faculty opinions&#10;"||string-join($faculty-opinions,'&#10;')
)

return string-join($strings,'&#10;')