import module namespace schematron = "http://github.com/Schematron/schematron-basex";

declare variable $sch := schematron:compile(doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/final-JATS-schematron.sch'));

for $x in collection('articles')//*:article[matches(descendant::*:article-id[@pub-id-type="publisher-id"],'^4222')]
let $article-id := $x//*:article-id[@pub-id-type="publisher-id"]/text()
let $folder := concat('/articles/elife-',$article-id,'-v')
let $v-no := number(substring-before(substring-after($x/base-uri(),$folder),'.xml'))
let $count := count(collection('articles')//*:article[descendant::*:article-id[@pub-id-type="publisher-id"]/text() = $article-id])
return if ($count != $v-no) then ()
else 

let $svrl := schematron:validate($x, $sch)
return if ($svrl//*:successful-report[@id="unlinked-url-2"]) then $x/base-uri()
else ()
