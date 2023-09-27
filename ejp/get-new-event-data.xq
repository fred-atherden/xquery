declare variable $folder := "/Users/fredatherden/Desktop/event-news-data/";
declare variable $email := "f.atherden@elifesciences.org";
declare variable $rows := 1000;

declare function local:getEventData($cursor as node(),$count as xs:integer) {
   let $response := http:send-request(<http:request method='get' href="{('https://api.eventdata.crossref.org/v1/events?mailto='||$email||'&amp;rows=1000&amp;source=newsfeed&amp;obj-id.prefix=10.7554&amp;cursor='||$cursor)}" timeout='30'/>)
   let $json := $response//*:json
   let $next-cursor := $json//*:next-cursor
   return 
   if (count($json/*:message/*:events/*) = $rows) then (
     file:write(($folder||$count||'.xml'),$json),
     (: Wait one second before making the next request :)
     prof:sleep(1000),
     local:getEventData($next-cursor,$count + 1)
   )
   else file:write(($folder||$count||'.xml'),$json)
};

if (file:exists($folder)) then (
 local:getEventData(<cursor/>,1) 
)
else (
  file:create-dir($folder),
  local:getEventData(<cursor/>,1)
)