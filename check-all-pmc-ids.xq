let $tool := 'basex'
let $email := 'f.atherden@elifesciences.org'
let $dois := distinct-values(
              for $x in collection('articles')//*:article[*:body]//*:article-meta/*:article-id[@pub-id-type="doi"]
              order by $x
              return $x)

let $responses := <responses>{
  (: Limit on 200 ids per query :)
  for tumbling window $ids in $dois
    start at $start when true()
    end at $end when $end - $start = 199
    let $id-string:= string-join($ids,',')
    let $response := http:send-request(
      <http:request method='get' href="{('https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?tool='||$tool||'&amp;email='||$email||'&amp;ids='||$id-string)}" timeout='10'>
        <http:header name="From" value="{$email}"/>
        <http:header name="User-Agent" value="{$tool}"/>
      </http:request>)
    return ($response)
  }</responses>

return ($responses//*:record[*:errmsg]/@requested-id/string(),
        $responses)