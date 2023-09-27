declare function local:is-generated($node as node()) as xs:boolean {
  switch ($node/name())
    case "related-object" return 
                          if ($node/parent::*:p/preceding-sibling::p[not(*:related-object)][1][contains(.,'generated')])
                             then true()
                          else false()
    case "element-citation" return 
                            if ($node/@specific-use="isSupplementedBy")
                               then true()
                            else false()
    default return (xs:QName("local:error"),($node/name()||' is not an allowed input. Only related-object or element-citation.'))
};


let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[@article-type="research-article" and *:body]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return 
    <item id="{$id}" pub-year="{$pub-year}" base="{$b}">{
      for $y in $x//*:sec[@sec-type=("data-availability","datasets")]//(*:element-citation|*:related-object)
      let $is-generated := local:is-generated($y)
      return <data is-generated="{$is-generated}">{$y}</data>    
    }</item>
  }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
  
for $year in distinct-values($list//*:item/@pub-year)
let $items := count($list//*:item[@pub-year=$year])
let $as-w-both-data := count($list//*:item[@pub-year=$year and *:data[@is-generated="true"] and *:data[@is-generated="false"]])
let $as-w-gen-data := count($list//*:item[@pub-year=$year and *:data[@is-generated="true"] and not(*:data[@is-generated="false"])])
let $as-w-pp-data := count($list//*:item[@pub-year=$year and *:data[@is-generated="false"] and not(*:data[@is-generated="true"])])
let $as-wo-data := count($list//*:item[@pub-year=$year and not(*:data)])
return $year||'	'||$items||'	'||$as-w-both-data||'	'||$as-w-gen-data||'	'||$as-w-pp-data||'	'||$as-wo-data