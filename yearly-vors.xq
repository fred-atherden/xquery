declare function local:get-yearly-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[*:body]
              let $pub-date := $x//*:article-meta/*:pub-date[@publication-format="electronic"]
              let $iso-pub-date := $pub-date/*:year||'-'||$pub-date/*:month||'-'||$pub-date/*:day
              let $one-year-ago := (current-date() - xs:yearMonthDuration("P1Y"))
              where $one-year-ago le xs:date($iso-pub-date)
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" pub-date="{$iso-pub-date}">{$b}</item>
              }</list>
  let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
                  }</list>
  return $list2
};

