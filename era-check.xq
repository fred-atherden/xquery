(: Return list of lastest version of articles :)
declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article
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
let $obsvr-url := 'https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?per-page=100&amp;page='
let $pages := (1,2)
let $text := string-join(for $page in $pages return fetch:text($obsvr-url||$page),'')
let $json := json:parse('['||
                replace(string-join(tokenize($text,'\n'),','),',$','')||
                ']')

let $eras := distinct-values(collection('era')//*:article/@id)

for $obj in $json//*:_
let $doi := $obj/*:doi
let $id := substring-after($doi,'10.7554/eLife.')
let $base-uri := $latest-articles//*:item[@id=$id]/text()
where not(empty($base-uri)) and not($id=$eras)
let $article := collection($base-uri)//*:article
return 
  if ($article//*:ext-link[contains(@*:href,'softwareheritage')]) then data($doi)
  else if ($article//*:supplementary-material/*:caption[matches(lower-case(.),'r\s?markdown|jupyter|notebook|python')]) then 
   ($doi||' file')
  else ()