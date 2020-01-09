for $x in collection('articles')//*:article[(@article-type="research-article") and *:body and not(descendant::*:sec[@sec-type="data-availability"])]
let $p := $x//*:article-meta//*:pub-date[(@date-type='pub') or (@date-type='publication')]
let $iso-date := concat($p/year,'-',$p/month,'-',$p/day)
let $subj := $x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject
order by $iso-date
return 
(substring-after($x/base-uri(),'elife-')
||
' --- '
||
$subj
||
' --- '
||
$iso-date
)
