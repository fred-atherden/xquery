distinct-values(let $regex := 'conceptualization[;,]?|data curation[;,]?|formal analysis[;,]?|funding acquisition[;,]?|investigation[;,]?|methodology[;,]?|project administration[;,]?|resources[;,]?|software[;,]?|supervision[;,]?|validation[;,]?|visualization[;,]?|writing—review and editing[;,]?|writing—original draft[;,]?'


for $x in collection('articles')//*:article//*:contrib[@contrib-type="author"]
let $name := concat($x/*:name/*:given-names,' ',$x/*:name/*:surname)
let $doi := $x/ancestor::*:article//*:article-meta//*:article-id[@pub-id-type="doi"]/text()
let $y := $x/*:xref[matches(@rid,'^con[\d]{1,2}$')]/@rid/string()
let $list := <list>{for $z in $x/ancestor::article/descendant::*:fn[@id/string() = $y]/*:p[1] return $z}</list>
return
if ($list = '') then () 
else if (matches(lower-case($list/*:p[1]),$regex)) then ()
else concat($list/*:p[1]/data(),' ---- ',$name,' ---- ',$doi)


)