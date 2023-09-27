declare function local:get-latest() as element() {
  let $list1 := <list>{
              for $x in collection('articles')//*:article[descendant::*:sec[@sec-type="data-availability"]]
              let $type := if ($x/*:body) then 'vor' else 'poa'
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" type="{$type}">{$b}</item>
             }</list>
  let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  let $type := $x/@type/string()
                  return
                  if ($x/following-sibling::*:item[1][@type=$type]/@id/string() = $id) then ()
                  else $x
  }</list>
  return $list2
};

declare function local:get-data-ref-count($base-uri as xs:string) as xs:integer {
  count(collection($base-uri)//*:sec[@sec-type="data-availability"]//(*:element-citation|*:related-object))
};

declare function local:get-data($base-uri as xs:string) as xs:string {
  data(collection($base-uri)//*:sec[@sec-type="data-availability"]//*:p[not(//(*:element-citation|*:related-object))])
};

let $list := local:get-latest()

for $vor in $list//*:item[@type="vor"]
where $vor/preceding-sibling::*:item[1][@id = $vor/@id and @type != $vor/@type]
let $poa := $vor/preceding-sibling::*:item[1][@id = $vor/@id and @type != $vor/@type]

let $vor-count := local:get-data-ref-count($vor/text())
let $poa-count := local:get-data-ref-count($poa/text())

where $vor-count != $poa-count
return 'vor :'||$vor/@id||' - '||$vor-count||' poa: '||$poa/@id||' - '||$poa-count