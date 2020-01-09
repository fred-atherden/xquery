import module namespace schematron = "http://github.com/Schematron/schematron-basex";

(: Compile schematron - need to account for gen-country-test which basex is unable to resolve :)
let $s := doc('/Users/fredatherden/Documents/github/elife-JATS-schematron/src/final-JATS-schematron.sch')
let $s2 := copy $copy:=$s
modify(
  for $x in $copy//*:assert[@id='gen-country-test'] 
  return delete node $x
)
return $copy
let $sch := schematron:compile($s2)

for $x in collection('articles')//*:article
let $article-id := $x//*:article-id[@pub-id-type="publisher-id"]/text()
let $folder := concat('/articles/elife-',$article-id,'-v')
let $v-no := number(substring-before(substring-after($x/base-uri(),$folder),'.xml'))
let $count := count(collection('articles')//*:article[descendant::*:article-id[@pub-id-type="publisher-id"]/text() = $article-id])

return 
(: Define a subset of articles based on regex against tracking number :)
if (not(matches($article-id,'^444'))) then ()
(: Only pick out latest version :)
else if ($count != $v-no) then ()
else 

  let $svrl := schematron:validate($x, $sch)
  return 
    (: Only return invalid articles :)
    if (schematron:is-valid($svrl) = true()) then ()
    else $x/base-uri()


