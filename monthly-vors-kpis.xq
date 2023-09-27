declare variable $month := '2023-06';
declare variable $article-types := ('research-article','research-advance','tools-resources','short-report');

declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article
              let $is-prc := if ($x//*:article-meta//*:custom-meta/*:meta-value='prc') then 'true'
                             else 'false'
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" is-prc="{$is-prc}">{$b}</item>
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

let $latest-articles := local:get-latest-article-list('articles')

let $json := 
  for $x in (1,2,3,4,5)
  let $text := fetch:text('https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?per-page=100&amp;page='||string($x))
  let $fixed-text := '['||replace(string-join(tokenize($text,'\n'),','),',$','')||']'
  return json:parse($fixed-text)

let $list := <list>{
              for $x in $json//*:_
              where $x/*:article-type=$article-types and starts-with($x/*:first-vor-published-date,$month)
              let $id := substring-after($x/*:doi,'e.')
              let $is-prc := $latest-articles//*:item[@id=$id]/@is-prc
              return <item doi="{$x/*:doi}" is-prc="{$is-prc}" type="{$x/*:article-type}" pub-date="{$x/*:first-vor-published-date}"/>
            }</list>

return (
  'Total VORs: '||count($list//*:item),
  'New model VORs: '||count($list//*:item[@is-prc="true"]),
  'Old model VORs: '||count($list//*:item[@is-prc="false"]),
  $list//*:item
)