let $folder := '/Users/fredatherden/Desktop/oa/'
let $store := '/Users/fredatherden/Documents/GitHub/elife-article-xml/articles/'

let $month := '2021-09'
let $pages := (1,2,3,4)

let $vor-url := 'https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?page='
let $vor-text := string-join(for $page in $pages return fetch:text($vor-url||$page),'')
let $json := json:parse('['||
                replace(replace(string-join(tokenize($vor-text,'\n'),','),',$',''),',,',',')||
                ']')
let $dois := distinct-values(for $x in $json//*:_
                where starts-with($x/*:first-vor-published-date,$month)
                return $x/*:doi)
let $latest-articles := let $list1 := <list>{
              for $x in collection('articles')//*:article
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
for $doi in $dois
let $id := substring-after($doi,'10.7554/eLife.')
let $node := $latest-articles//*:item[@id=$id]
let $filename := substring-after($node/text(),'/articles/')
let $location := ($store||$filename)
let $article-type := lower-case(doc($location)//*:article//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject)
let $target := ($folder||$filename)
where not($article-type=('editorial','correction','retraction','feature article','insight','expression of concern'))
return file:copy($location,$target)