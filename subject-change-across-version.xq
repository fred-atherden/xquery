let $list := <list>{
for $x in collection('articles')//*:article
let $article-id := $x//*:article-id[@pub-id-type="publisher-id"]/text()
let $b := $x/base-uri()
let $count := count(collection('articles')//*:article[descendant::*:article-id[@pub-id-type="publisher-id"]/text() = $article-id])
let $subj := <subjects>{
              for $y in $x//*:article-categories//*:subj-group[@subj-group-type="heading"]
              return 
              <subject>{$y/*:subject/data()}</subject>
              }</subjects>
              
return if ($count = 1) then ()
else if ($subj = '') then ()
else <item base="{$b}" article-id="{$article-id}">{$subj}</item>
}</list>

return <list>{
        for $x in $list//*:item
        let $id := $x/@article-id
        return
        if ($list//*:item[@article-id = $id]/*:subjects != $x/*:subjects) then $x
        else ()
}</list>