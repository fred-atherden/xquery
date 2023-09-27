declare function local:get-name($name as element()) as xs:string{
  if ($name/given-names[1] and $name/surname[1] and $name/suffix[1])
    then concat($name/given-names[1],' ',$name/surname[1],' ',$name/suffix[1])
  else if (not($name/given-names[1]) and $name/surname[1] and $name/suffix[1])
    then concat($name/surname[1],' ',$name/suffix[1])
  else if ($name/given-names[1] and $name/surname[1] and not($name/suffix[1]))
    then concat($name/given-names[1],' ',$name/surname[1])
  else if (not($name/given-names[1]) and $name/surname[1] and not($name/suffix[1]))
    then $name/surname[1]
};

let $list-1 := <list>{
              for $x in collection('articles')//*:article
              let $b := $x/base-uri()
              order by $b
              return <item>{$b}</item>
             }</list>

let $latest-list := <list>{for $x in $list-1/*:item
  let $id := substring-before(substring-after($x,'/articles/elife-'),'-v')
  return
  if (substring-before(substring-after($x/following-sibling::*:item[1],'/articles/elife-'),'-v') = $id) then ()
  else <item id="{$id}">{$x/string()}</item>}</list>

(: Downloaded here https://docs.google.com/spreadsheets/d/1dvhq-7XfLSSx8AN2wlnj8PXG-_tOGFGanhzfYxvEFdQ/edit#gid=0 :)
let $csv := csv:parse(file:read-text('/Users/fredatherden/Desktop/era.csv'))
(: Downloaded here https://docs.google.com/spreadsheets/d/1hEay8ewBk6Ieygp5WeXiaH7FtxxlQtyZ6kCFKfMDVH8/edit#gid=0 :)
let $contacted := csv:parse(file:read-text('/Users/fredatherden/Desktop/contacted.csv'))

let $new-contacted := <list>{
  for $y in $contacted//*:record[position() gt 1]
  return <item>{substring-after($y/*:entry[3],'articles/')}</item>
}</list>



for $x in $csv//*:record[(position() gt 1) and normalize-space(*:entry[2]) != '']
let $id := analyze-string($x/*:entry[1],'\d{5}')//*:match/data()
let $d := lower-case($x/*:entry[2])
let $latest := $latest-list//*:item[@id=$id]/text()
let $article := collection($latest)//*:article
let $email := string-join($article//*:article-meta//*:contrib[@contrib-type="author" and @corresp="yes"]/*:email,'; ')
let $names := string-join(for $y in $article//*:article-meta//*:contrib[@contrib-type="author" and @corresp="yes"]/*:name return local:get-name($y),'; ')
let $type := lower-case($article//*:article-meta/*:article-categories/*:subj-group[@subj-group-type="display-channel"][1]/*:subject[1])
return 
  if ($id = $new-contacted//*:item/text()) then 
              ($x/*:entry[1]||'	'||'Emailed	'||$x/*:entry[3]||'	'||$x/*:entry[4]||'	'||$email||'	'||$names)
  else if ((normalize-space($x/*:entry[2])='') and $type='tools and resources') then
              ($x/*:entry[1]||'	'||'No	'||$x/*:entry[3]||'	Tools and resources	'||$email||'	'||$names)
  else ($x/*:entry[1]||'	'||$x/*:entry[2]||'	'||$x/*:entry[3]||'	'||$x/*:entry[4]||'	'||$email||'	'||$names)
