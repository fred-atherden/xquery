<list>
{for $x in collection('articles')//*:article
let $id := $x//*:article-id[@pub-id-type="publisher-id"]
let $type := $x/@article-type
let $subj := $x//*:subj-group[@subj-group-type="display-channel"]/*:subject
return if ($x//*:table-wrap[not(child::*:label)]) then (<item id="{$id}" type="{$type}" subject="{$subj}"/>)
else ()
}</list>