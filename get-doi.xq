let $title := 'Manual of Afrotropical Diptera'
let $title-query := encode-for-uri(replace(translate($title,' \?',''),'\s','+'))
let $crossref := http:send-request(<http:request method='get' href="{('https://api.crossref.org/works?rows=3&amp;query.bibliographic='||$title-query||'&amp;mailto=f.atherden@elifesciences.org')}" timeout='2'><http:header name="User-Agent" value="f.atherden@elifesciences.org"/></http:request>)

return <result>{
if ($crossref//*:items/*:_)
  then (<ref>{
  (
    <title>{$title}</title>,
    for $item in $crossref//*:items/*:_
    let $i-title := $item/*:title[1]/data()
    let $lr := strings:levenshtein($title,$i-title)
    let $likelihood := if ($lr lt 0.8) then 'low' 
                       else if ($lr lt 0.9) then 'medium'
                       else 'high'
    order by (1-$lr)
    return 
    <item likelihood="{$likelihood}" levenshtein-ratio="{substring(string($lr),1,5)}" doi="{$item/*:DOI[1]}" type="{$item/*:type[1]}">{$i-title}</item>
  )
}</ref>
  ) 
else (<ref>{(<title>{$title}</title>,$crossref)}</ref>)
}</result>