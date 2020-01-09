let $list := 
<list>{
for $x in collection('articles')//*:article
let $no := $x//*:article-meta/*:article-id[@pub-id-type="publisher-id"]/data()
let $doi := ('http://doi.org/'||$x//*:article-meta/*:article-id[@pub-id-type="doi"]/data())
return <item no="{$no}" doi="{$doi}">{$x//*:article-meta//*:article-title}</item>
}</list>

for $x in $list//*:item
let $no := $x/@no
order by $no
return if (count($x/preceding::*:item[@no=$no])>3) then $x
else ()