declare variable $folder := "/Users/fredatherden/Desktop/orcid-data/";
declare variable $email := "f.atherden@elifesciences.org";
declare variable $rows := 1000;

declare function local:getOrcidData($cursor as node(), $count as xs:integer) {
  if ($cursor/@type="null" or empty($cursor)) then ()
  else (
   let $response := http:send-request(<http:request method='get' href="{('https://api.crossref.org/v1/members/4374/works?mailto='||$email||'&amp;filter=type:journal-article&amp;select=DOI,published-online,author&amp;rows='||$rows||'&amp;cursor='||web:encode-url($cursor))}" timeout='60'/>)
   let $json := $response//*:json
   let $next-cursor := $json//*:next-cursor
   where count($json/*:message/*:items/*) = $rows
   return (
     file:write(($folder||$count||'.xml'),$json),
     (: Wait one second before making the next request :)
     prof:sleep(1000),
     local:getOrcidData($next-cursor, $count + 1)
   )
  )
};

if (file:exists($folder)) then (
 local:getOrcidData(<cursor>*</cursor>,1) 
)
else (
  file:create-dir($folder),
  local:getOrcidData(<cursor>*</cursor>,1)
)