declare variable $folder := "/Users/fredatherden/Desktop/funder-data/";
declare variable $email := "f.atherden@elifesciences.org";
declare variable $rows := 1000;

declare function local:getEventData($cursor as node(),$count as xs:integer) {
  if ($cursor/@type="null" or empty($cursor)) then ()
  else (
    let $response := http:send-request(<http:request method='get' href="{('https://api.crossref.org/v1/members/4374/works?mailto='||$email||'&amp;filter=type:journal-article&amp;select=DOI,funder,published-online&amp;rows='||$rows||'&amp;cursor='||web:encode-url($cursor))}" timeout='60'/>)
   let $json := $response//*:json
   let $next-cursor := $json//*:next-cursor
   return if (count($json/*:message/*:items/*) = $rows) then (
     file:write(($folder||$count||'.xml'),$json),
     (: Wait one second before making the next request :)
     prof:sleep(1000),
     local:getEventData($next-cursor,$count + 1)
   )
   else file:write(($folder||$count||'.xml'),$json)
  )
};

if (file:exists($folder)) then (
 local:getEventData(<cursor>*</cursor>,1) 
)
else (
  file:create-dir($folder),
  local:getEventData(<cursor>*</cursor>,1)
)