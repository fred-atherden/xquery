(: Check eLife DOIs have an entry in PMC
   $lower and $upper variables need changing in order to get a slice of <= 200 dois
 :)

declare namespace elife = 'elife';

let $tool := 'basex'
let $email := 'f.atherden@elifesciences.org'
let $dois := 
  distinct-values(
    for $x in collection('articles')//*:article[*:body]//*:article-meta/*:article-id[@pub-id-type="doi"]
    order by $x
    return $x)
let $lower := 14599
let $upper := 14800
(: Get 199 ids :)
let $ids := $dois[position() > $lower and position() < $upper]
let $id-string := string-join($ids,',')

let $response := 
  (: Limit on 200 ids per query :)
  if (count($ids) gt 200) then error(
        xs:QName("elife:error"),
        (count($ids)||' is too many ids for this api request'))
  (: Don't query no ids :)
  else if (count($ids) = 0) then error(
        xs:QName("elife:error"),
        (count($ids)||' ids in that slice'))
  else (
 http:send-request(
  <http:request method='get' href="{('https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?tool='||$tool||'&amp;email='||$email||'&amp;ids='||$id-string)}" timeout='10'>
    <http:header name="From" value="{$email}"/>
    <http:header name="User-Agent" value="{$tool}"/>
  </http:request>))
  
return (
  for $id in $ids
  return if ($response//*:record[@doi/string() = $id]/*:errmsg) then $id
  else ()
  ,
  $response
)
