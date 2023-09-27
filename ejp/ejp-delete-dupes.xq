let $db := 'ejp-2012'

let $later-ids := (
  distinct-values(collection('ejp-2021')//*:manuscript-number),
  distinct-values(collection('ejp-2020')//*:manuscript-number),
  distinct-values(collection('ejp-2019')//*:manuscript-number),
  distinct-values(collection('ejp-2018')//*:manuscript-number),
  distinct-values(collection('ejp-2017')//*:manuscript-number),
  distinct-values(collection('ejp-2016')//*:manuscript-number),
  distinct-values(collection('ejp-2015')//*:manuscript-number),
  distinct-values(collection('ejp-2014')//*:manuscript-number),
  distinct-values(collection('ejp-2013')//*:manuscript-number)
)

let $db-ids := distinct-values(collection($db)//*:manuscript-number)

let $old-db-ids := for $x in $db-ids
                   where $x=$later-ids
                   return $x
 
for $x in collection($db)//*:xml
let $ms-nos := $x//*:manuscript-number/data()
where some $y in $ms-nos satisfies $y = ($old-db-ids)
return db:delete($db,substring-after($x/base-uri(),'/'||$db||'/'))