declare function local:get-name($name) as xs:string* {
  if ($name/name() = 'name') then (
    if ($name/given-names[1] and $name/surname[1] and $name/suffix[1]) then concat($name/given-names[1],' ',$name/surname[1],' ',$name/suffix[1])
    else if (not($name/given-names[1]) and $name/surname[1] and $name/suffix[1]) then concat($name/surname[1],' ',$name/suffix[1])
    else if ($name/given-names[1] and $name/surname[1] and not($name/suffix[1])) then concat($name/given-names[1],' ',$name/surname[1])
    else $name/surname[1]
  )
 else if ($name/*) then ($name/*[1]/text()[1])
 else (
   $name/data()
 )
};

declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[*:body]//*:article-meta/*:contrib-group[1]/*:contrib[@contrib-type="author"]
              let $name := local:get-name(($x/*:name[1]|$x/*:collab[1]))
              order by $name
              return if ($x/*:contrib-id) then <item id="{substring-after($x/*:contrib-id[1],'orcid.org/')}">{$name}</item>
                     else <item>{$name}</item>
              }</list>

  let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  let $n := $x/data()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else if ((not($id) or $id='') and $x/following-sibling::*:item[not(@id)]/data()=$n) then ()
                  else $x
                  }</list>

  return $list2
};

let $articles := local:get-latest-article-list('articles')
return $articles