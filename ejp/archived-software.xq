let $regex := 'elifesciences-publications|softwareheritage\.org'

let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[@article-type="research-article" and *:body]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    let $github := count($x//(*:ext-link[contains(lower-case(@*:href),"elifesciences-publications")]|*:uri[contains(lower-case(@*:href),"elifesciences-publications")]))
    let $swh := count($x//(*:ext-link[contains(lower-case(@*:href),"softwareheritage.org")]|*:uri[contains(lower-case(@*:href),"softwareheritage.org")]))
    order by $b
    return <item id="{$id}" pub-year="{$pub-year}" base="{$b}" github="{$github}" swh="{$swh}"/>
    }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
for $year in distinct-values($list//*:item/@pub-year)
let $items := $list/*:item[@pub-year=$year]
let $has-archived := count($items[@github!="0" or @swh!="0"])
let $has-git := count($items[@github!="0"])
let $git-count := sum($items/@github)
let $has-swh := count($items[@swh!="0"])
let $swh-count := sum($items/@swh)
let $archived-count := $git-count + $swh-count
return $year||'	'||count($items)||'	'||$has-archived||'	'||$archived-count||'	'||$has-git||'	'||$git-count||'	'||$has-swh||'	'||$swh-count