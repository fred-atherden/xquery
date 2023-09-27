let $list := <list>{
              for $x in collection('articles')//*:article[descendant::*:media[@mimetype="video"]]
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" base-uri="{$b}">{for $y in $x//*:media[@mimetype="video"] return $y}</item>
              }</list>
         
for $x in $list//*:item[(@id = preceding-sibling::*/@id) and media[contains(@id,'video')]]
let $versions := $x/preceding-sibling::*[@id = $x/@id]
return if (some $version in $versions satisfies ($version/*:media[contains(@id,'media')]))
  then ($x/@base-uri||'	'||string-join($versions[*:media[contains(@id,'media')]]/@base-uri,'	'))
