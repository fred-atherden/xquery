let $list-1 := <list>{
              for $x in collection('articles')//*:article
              let $b := $x/base-uri()
              order by $b
              return <item>{$b}</item>
             }</list>
             
let $list := <list>{
  for $x in $list-1/*:item
  let $id := substring-before(substring-after($x,'/articles/elife-'),'-v')
  return
  if (substring-before(substring-after($x/following-sibling::*:item[1],'/articles/elife-'),'-v') = $id) then ()
  else <item>{$x/string()}</item>
}</list> 

let $csv := 
<csv>{(
 <record><entry>{'doi'}</entry><entry>{'Acceptance summary?'}</entry></record>
 ,
for $x in collection('articles')//*:article[*:sub-article and *:body and base-uri()=$list//*:item/text()]
let $doi := ('http://doi.org/'||$x/*:front/*:article-meta//*:article-id[@pub-id-type="doi"])
return 
  if ($x//*:sub-article[contains(.,'Acceptance summary') or contains(.,'Acceptance Summary')]) 
      then <record><entry>{$doi}</entry><entry>{'yes'}</entry></record>
  else <record><entry>{$doi}</entry><entry>{'no'}</entry></record> 
)
} </csv>
  
  
  return file:write('/Users/fredatherden/Desktop/accept-sum.csv',$csv, map{'method':'csv'})