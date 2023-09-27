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

declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[@article-type="research-article" and *:body]
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by 1 - number($id)
              return <item id="{$id}">{$b}</item>
              }</list>
 
  let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
                  }</list>

  return $list2
};

(: Already contacted about ERA:
   - https://docs.google.com/spreadsheets/d/1dvhq-7XfLSSx8AN2wlnj8PXG-_tOGFGanhzfYxvEFdQ/edit#gid=0
   - https://docs.google.com/spreadsheets/d/1hEay8ewBk6Ieygp5WeXiaH7FtxxlQtyZ6kCFKfMDVH8/edit#gid=0 :)
let $old := <list>
    (: already in touch via CRM :)
    <item id="52258"/>
    <item id="30274"/>
    <item id="55862"/>
    <item id="43154"/>
    <item id="47314"/>
    <item id="57067"/>
    <item id="60287"/>
    <item id="61523"/>
    <item id="54082"/>
    <item id="55650"/>
    <item id="55119"/>
    <item id="43415"/>
    <item id="61277"/>
    <item id="61504"/>
    <item id="49020"/>
    <item id="45068"/>
        
    <item id="54795"/>
    <item id="54348"/>
    <item id="60122"/>
    <item id="60080"/>
    <item id="58785"/>
    <item id="54082"/>
    <item id="58621"/>
    <item id="58124"/>
    <item id="58097"/>
    <item id="57788"/>
    <item id="57784"/>
    <item id="57191"/>
    <item id="57022"/>
    <item id="56829"/>
    <item id="55308"/>
    <item id="55217"/>
    <item id="55173"/>
    <item id="55119"/>
    <item id="54822"/>
    <item id="54066"/>
    <item id="53885"/>
    <item id="53807"/>
    <item id="53684"/>
    <item id="53535"/>
    <item id="53226"/>
    <item id="53008"/>
    <item id="60066"/>
    <item id="59988"/>
    <item id="59099"/>
    <item id="58828"/>
    <item id="58810"/>
    <item id="58699"/>
    <item id="58660"/>
    <item id="58556"/>
    <item id="58511"/>
    <item id="58041"/>
    <item id="58019"/>
    <item id="57872"/>
    <item id="57149"/>
    <item id="57148"/>
    <item id="57093"/>
    <item id="56922"/>
    <item id="56839"/>
    <item id="56717"/>
    <item id="56079"/>
    <item id="55778"/>
    <item id="55659"/>
    <item id="55650"/>
    <item id="55619"/>
    <item id="54880"/>
    <item id="54318"/>
    <item id="54129"/>
    <item id="53933"/>
    <item id="53916"/>
    <item id="53433"/>
    <item id="53432"/>
    <item id="53392"/>
    <item id="53085"/>
    <item id="52775"/>
    <item id="52648"/>
    <item id="52611"/>
    <item id="51254"/>
    <item id="50804"/>
    <item id="50469"/>
    <item id="50060"/>
    <item id="49658"/>
    <item id="49305"/>
    <item id="49115"/>
    <item id="48694"/>
    <item id="48434"/>
    <item id="46418"/>
    <item id="45594"/>
    <item id="45079"/>
    <item id="44937"/>
    <item id="43994"/>
    <item id="43696"/>
    <item id="43482"/>
    <item id="43478"/>
    <item id="43415"/>
    <item id="42693"/>
    <item id="42409"/>
    <item id="42388"/>
    <item id="41769"/>
    <item id="41723"/>
    <item id="41586"/>
    <item id="41461"/>
    <item id="41124"/>
    <item id="41050"/>
    <item id="40969"/>
    <item id="40947"/>
    <item id="40618"/>
    <item id="56801"/>
    <item id="56879"/>
    <item id="57571"/>
    <item id="54530"/>
    <item id="56325"/>
    <item id="53948"/>
    <item id="53560"/>
    <item id="53968"/>
    <item id="50103"/>
    <item id="54074"/>
    <item id="53060"/>
    <item id="53275"/>
    <item id="50608"/>
    <item id="55570"/>
    <item id="53237"/>
    <item id="51325"/>
    <item id="50901"/>
    <item id="51984"/>
    <item id="51089"/>
    <item id="53500"/>
    <item id="49630"/>
    <item id="48460"/>
    <item id="50465"/>
    <item id="49921"/>
    <item id="52153"/>
    <item id="52542"/>
    <item id="47889"/>
    <item id="49501"/>
    <item id="49801"/>
    <item id="49020"/>
    <item id="46965"/>
    <item id="47301"/>
    <item id="50375"/>
    <item id="48175"/>
    <item id="47612"/>
    <item id="48548"/>
    <item id="49212"/>
    <item id="46923"/>
    <item id="44454"/>
    <item id="42906"/>
    <item id="40845"/>
    <item id="43668"/>
    <item id="45374"/>
    <item id="45068"/>
    <item id="46793"/>
    <item id="47091"/>
    <item id="44939"/>
    <item id="45474"/>
    <item id="44590"/>
    <item id="44279"/>
    <item id="44344"/>
    <item id="41641"/>
    <item id="54875"/>
    <item id="55678"/>
    <item id="53558"/>
    <item id="55414"/>
    <item id="55913"/>
    <item id="45539"/>
    <item id="56053"/>
    <item id="54100"/>
    <item id="55159"/>
    <item id="48714"/>
    <item id="52426"/>
    <item id="51963"/>
    <item id="52091"/>
    <item id="55002"/>
    <item id="49840"/>
    <item id="46015"/>
    <item id="48901"/>
    <item id="51975"/>
    <item id="48063"/>
    <item id="49720"/>
    <item id="50749"/>
    <item id="46966"/>
    <item id="48571"/>
    <item id="48779"/>
    <item id="48994"/>
    <item id="43243"/>
    <item id="46935"/>
    <item id="42496"/>
    <item id="46754"/>
    <item id="49324"/>
    <item id="46922"/>
    <item id="38805"/>
    <item id="46080"/>
    <item id="42448"/>
    <item id="47040"/>
    <item id="44324"/>
    <item id="45403"/>
</list>


let $list := local:get-latest-article-list('articles')

for $x in $list//*:item
let $id := $x/@id
where not($old/*:item[@id=$id])

let $article := collection($x/text())
let $url := ('https://elifesciences.org/articles/'||$id||'/figures#data')
let $email := string-join($article//*:article-meta//*:contrib[@contrib-type="author" and @corresp="yes"]/*:email,'; ')
let $names := string-join(for $y in $article//*:article-meta//*:contrib[@contrib-type="author" and @corresp="yes"]/*:name return local:get-name($y),'; ')
let $type := lower-case($article//*:article-meta/*:article-categories/*:subj-group[@subj-group-type="display-channel"][1]/*:subject[1])
let $text := ($url||'	'||$type||'		'||$email||'	'||$names)

return 
  if ($article//*:ext-link[contains(@*:href,'softwareheritage') or contains(@*:href,'elifesciences-publications')])
    then ('code archived	'||string-join(for $y in $article//*:ext-link[contains(@*:href,'softwareheritage') or contains(@*:href,'elifesciences-publications')] return $y,'; ')||'	'||$text)
  else if (contains(lower-case($article),'markdown')) 
    then ('markdown mention		'||$text)
  else if (contains(lower-case($article),'notebook')) 
    then ('notebook mention		'||$text)
  else ()
  
