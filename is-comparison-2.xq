let $db := 'articles'
let $folder := '/Users/fredatherden/Desktop/pre-edit-impact'

let $impact-statements := <list>{
  for $c in  collection('articles')//*:article//*:custom-meta[*:meta-name='Author impact statement']/*:meta-value
  let $id := $c/ancestor::*:article//*:article-id[@pub-id-type="publisher-id"][1]/data()
  let $v := substring-before(substring-after($c/base-uri(),'-v'),'.xml')
  return if (starts-with($id,'4') or starts-with($id,'5')) then <item id="{$id}" version="{$v}">{$c/data()}</item>
  else ()
}</list>


let $files := file:list($folder, true(), '*.xml')
 for $z in $files
  let $article := doc($folder||'/'||$z)
  let $article-id := $article/descendant::*:article-id[@pub-id-type="publisher-id"][1]/data()
  let $subj := $article//*:article-meta/article-categories/subj-group[@subj-group-type='display-channel']/subject[1]/data()
  let $impact-statement := $article//*:custom-meta[*:meta-name='Author impact statement']/*:meta-value/data()
  let $latest-version := max(
     for $y in $impact-statements//*:item[@id/string() = $article-id]
     return number($y/@version/string())
   )
  let $published-impact-statement :=  $impact-statements//*:item[(@id/string() = $article-id) and (@version/string() = string($latest-version))]/data()
  let $status := if ($impact-statement=$published-impact-statement) then () else 'changed'
  
  return
  if ($impact-statements//*:item[@version/string() = string($latest-version)]) then 
  (
  $article-id||
  '	'||
  $subj||
  '	'||
  $impact-statement||
  '	'||
  $published-impact-statement||
  '	'||
  $status
)

else ()