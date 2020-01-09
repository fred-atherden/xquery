let $c := <csv>

{for $x in collection('articles')//*:article[@article-type="research-article"][descendant::*:body]
let $id := $x/descendant::*:article-id[@pub-id-type="publisher-id"]/text()
let $type := normalize-space($x/descendant::*:article-categories/*:subj-group[@subj-group-type="display-channel"]/data())
let $count := count($x//*:object-id[@pub-id-type="doi"])
return 
<record><entry>{$id}</entry><entry>{$type}</entry><entry>{$count}</entry></record>
}</csv>

return file:write('/Users/fredatherden/Desktop/component-dois.csv',$c, map { "method": "csv", "item-separator": "," })