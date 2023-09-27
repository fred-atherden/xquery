declare function local:get-orcid-count($node) {
  if ($node/name()='article') then (
    count($node//*:article-meta/*:contrib-group/*:contrib[@contrib-type="author" and descendant::*:contrib-id[@contrib-id-type="orcid"]])
  )
  else if ($node/name()='xml') then (
    count(
      for $x in $node/*:manuscript/*:version[last()]/*:authors/*:author/*:author-person-id
      let $person := $x/ancestor::*:xml/*:people/*:person[*:person-id[. = $x/string()]]
      where $person/*:memberships/*:membership[lower-case(*:member-type[1])="orcid"]/*:member-id
      return $x
    )
  )
  else error
};

let $article-list := 
  let $list :=  <list>{
    for $x in collection('articles')//*:article
    let $v := if ($x/*:body) then 'vor' else 'poa'
    let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return <item id="{$id}" version="{$v}" pub-year="{$pub-year}">{$b}</item>
    }</list>
  return <list>{
    for $x in $list/*:item
    let $v := $x/@version
    let $id := $x/@id/string()
    return 
      if ($v='poa' and $x/preceding-sibling::*:item[1][@id=$id and @version=$v]) then ()
      else if ($v='vor' and $x/following-sibling::*:item[1][@id=$id and @version=$v]) then ()
      else $x
  }</list> 

for $year in distinct-values($article-list//*:item/@pub-year)
  let $ids := distinct-values($article-list//*:item[@pub-year = $year]/@id)
  let $poas := for $x in $article-list//*:item[@id=$ids and @version="poa"] 
               where $x/following-sibling::*[1][@id=$x/@id and @version="vor"]
               return $x
  let $vors := for $x in $article-list//*:item[@id=$ids and @version="vor"] 
              where $x/preceding-sibling::*[1][@id=$x/@id and @version="poa"]
              return $x
  let $poa-o-count := sum(for $poa in $poas return local:get-orcid-count(collection($poa/text())//*:article))
  let $vor-o-count := sum(for $vor in $vors return local:get-orcid-count(collection($vor/text())//*:article))
return 
($year||'	'||count($ids)||'	'||$poa-o-count||'	'||$vor-o-count)