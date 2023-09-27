let $db := 'articles'
let $folder := '/Users/fredatherden/Desktop/pre-edit-impact'

let $files := file:list($folder, true(), '*.xml')
 for $z in $files
  let $article := doc($folder||'/'||$z)
  let $article-id := $article/descendant::*:article-id[@pub-id-type="publisher-id"][1]/data()
  let $impact-statement := serialize($article//*:custom-meta[*:meta-name='Author impact statement']/*:meta-value/(*|text()))
  let $latest-version := max(
     for $y in collection('articles')//*:article[descendant::*:article-id[@pub-id-type="publisher-id"][1]/data()=$article-id]
     return number(substring-before(substring-after($y/base-uri(),'-v'),'.xml'))
   )
  let $latest-version-uri := ('/'||$db||'/elife-'||$article-id||'-v'||$latest-version||'.xml')
  let $published-impact-statement :=  serialize(collection('articles')//*:article[base-uri()=$latest-version-uri]//*:custom-meta[*:meta-name='Author impact statement']/*:meta-value/(*|text()))
  let $status := if ($impact-statement=$published-impact-statement) then () else 'changed'
  
  return
  (
  $article-id||
  '	'||
  $impact-statement||
  '	'||
  $published-impact-statement||
  '	'||
  $status
)