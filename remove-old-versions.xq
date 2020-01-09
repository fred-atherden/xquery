for $x in collection('articles')//*:article
let $article-id := $x//*:article-id[@pub-id-type="publisher-id"]/text()
let $filename := substring-after($x/base-uri(),'/articles/')
let $folder := concat('/articles/elife-',$article-id,'-v')
let $v-no := number(substring-before(substring-after($x/base-uri(),$folder),'.xml'))
let $count := count(collection('articles')//*:article[descendant::*:article-id[@pub-id-type="publisher-id"]/text() = $article-id])
return if ($count = $v-no) then ()
else (db:delete('articles',$filename))