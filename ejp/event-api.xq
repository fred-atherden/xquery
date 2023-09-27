declare variable $folder := "/Users/fredatherden/Desktop/event-data/";
declare variable $email := "f.atherden@elifesciences.org";

declare function local:getEventData($cursor as node()) {
  if ($cursor/@type="null") then ()
  else (
   let $response := http:send-request(<http:request method='get' href="{('https://api.eventdata.crossref.org/v1/events?mailto='||$email||'&amp;rows=1000&amp;source=hypothesis&amp;obj-id.prefix=10.7554&amp;cursor='||$cursor)}" timeout='10'/>)
   let $json := $response//*:json
   let $next-cursor := $json//*:next-cursor
   let $filename := if ($cursor/data()="") then 'first' else ($cursor)
   return (
     file:write(($folder||$filename||'.xml'),$json),
     local:getEventData($next-cursor)
   )
  )
};

if (file:exists($folder)) then (
 local:getEventData(<cursor/>) 
)
else (
  file:create-dir($folder),
  local:getEventData(<cursor/>)
)