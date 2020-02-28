let $xml := doc('/Users/fredatherden/Downloads/elife48685.xml')

return <result file="{$xml/base-uri()}">{
for $ref in $xml//*:ref-list//*:element-citation[@publication-type=('journal','book') and not(*:pub-id[@pub-id-type="doi"]) and (*:article-title or *:chapter-title) and not(*:comment)]
let $title := $ref/(*:article-title|*:chapter-title)/data()
(: Test - see https://github.com/CrossRef/rest-api-doc#works-field-queries:)
let $auth-query := encode-for-uri(string-join(
                      for $auth in $ref/*:person-group[@person-group-type="author"]/*:name 
                      return ($auth/*:given-names||'+'||$auth/*:surname)
                      ,'+'))
let $title-query := encode-for-uri(replace(translate($title,' \?',''),'\s','+'))
let $crossref := http:send-request(<http:request method='get' href="{('https://api.crossref.org/works?rows=3&amp;query.bibliographic='||$title-query||'&amp;mailto=f.atherden@elifesciences.org')}" timeout='2'><http:header name="User-Agent" value="f.atherden@elifesciences.org"/></http:request>)

return 
if ($crossref//*:items/*:_)
  then (<ref id="{$ref/parent::*:ref/@id}" type="{$ref/@publication-type/string()}">{
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
else (<ref id="{$ref/parent::*:ref/@id}" type="{$ref/@publication-type/string()}">{(<title>{$title}</title>,$crossref)}</ref>)
}</result>