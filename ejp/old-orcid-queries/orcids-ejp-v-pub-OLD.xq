(: OLD - will not provide useful information since ORCIDs are sent back to eJP during production process :)

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

(: Output from all-ejp-ms.xq :)
let $ejp-list := doc('/Users/fredatherden/Desktop/ejp.xml')

let $article-list := 
  let $list :=  <list>{
    for $x in collection('articles')//*:article
    let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")]/*:year/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return <item id="{$id}" pub-year="{$pub-year}">{$b}</item>
    }</list>
  return <list>{
    for $x in $list/*:item
    let $id := $x/@id/string()
    return if ($x/following-sibling::*:item[1]/@id/string() = $id) then () else $x
  }</list>

for $year in distinct-values($article-list//*:item/@pub-year)
order by $year
let $items := $article-list//*:item[@pub-year = $year]
let $pub-count := count($items)
let $ids := $items/@id/string()
let $ejp-base-uris := distinct-values($ejp-list//*:item[@id = $ids]/@base-uri)
let $article-orcid-count := sum(for $x in $items return local:get-orcid-count(collection($x/text())/*:article))
let $ejp-orcid-count := sum(
                          for $x in $ejp-base-uris
                          return if ($x) then local:get-orcid-count(collection($x)//*:xml) else 0
                        )

return $year||'	'||$pub-count||'	'||$article-orcid-count||'	'||$ejp-orcid-count