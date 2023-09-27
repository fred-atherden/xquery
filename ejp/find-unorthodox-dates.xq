let $year := '2018'
let $db := 'ejp-'||$year

let $regex := '^\d{4}-\d{2}-\d{2}T'

for $x in (
          collection($db)//*:xml//*:version/*:history/*:stage/*:start-date,
          collection($db)//*:xml//*:version/*:emails/*:email/*:email-date
      )
where not(matches($x,$regex))
return $x