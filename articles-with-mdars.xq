declare variable $month := '^2023-04|^2023-05|^2023-06';

declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[//*:supplementary-material[contains(.,'MDAR')]]
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}">{$b}</item>
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
              where matches($x/*:first-vor-published-date,$month)
              order by $x/*:first-vor-published-date descending
              return <item doi="{$x/*:doi}" pub-date="{$x/*:first-vor-published-date}"/>
            }</list>

return $list//*:item/@doi/string()