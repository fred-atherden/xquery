declare variable $month := '2023-06';
declare variable $article-types := ('research-article','research-advance','tools-resources','short-report');

declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              let $accept-node := $x//*:article-meta/*:history/*:date[@date-type="accepted"]
              let $accept := if ($accept-node/@iso-8601-date) then $accept-node/@iso-8601-date
                            else $accept-node/*:year[1]||'-'||$accept-node/*:month[1]||'-'||$accept-node/*:day[1]
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" accept="{$accept}">{$b}</item>
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

declare function local:median($vals){
  let $values := for $x in $vals order by number($x) ascending return $x
  let $count := count($values)
  let $median-number :=  if (($count mod 2)=1) then (($count div 2)+0.5)
                         else (
                            ($count div 2),
                            (($count div 2)+1)
                         )

  let $median := if (count($median-number)=1) then (
                              for $x at $p in $values
                              where $p=$median-number
                              return $x
                                              )
                 else (sum(for $x at $p in $values
                           where $p=$median-number
                           return number($x)) div 2)

  return $median
};


let $latest-articles := local:get-latest-article-list('articles')

let $json := 
  for $x in (1,2,3,4,5)
  let $text := fetch:text('https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?per-page=100&amp;page='||string($x))
  let $fixed-text := '['||replace(string-join(tokenize($text,'\n'),','),',$','')||']'
  return json:parse($fixed-text)

let $list := <list>{
              for $x in $json//*:_
              where $x/*:article-type=$article-types and starts-with($x/*:first-vor-published-date,$month)
              return <item doi="{$x/*:doi}" pub-date="{$x/*:first-vor-published-date}"/>
            }</list>

let $tat-list := <list>{
                   for $x in $list//*:item
                   let $id := substring-after($x/@doi,'10.7554/eLife.')
                   let $accept := $latest-articles//*:item[contains(.,$id)]/@accept
                   let $tat := days-from-duration(xs:date($x/@pub-date) - xs:date($accept))
                   order by $tat descending
                   return <item doi="{$x/@doi}" pub-date="{$x/@pub-date}" accept="{$accept}" tat="{$tat}"/>
                 }</list>

return (
  local:median($tat-list//*:item/@tat/string()),
  $tat-list
)