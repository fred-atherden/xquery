declare function local:match($node as node(),$regex as xs:string) as xs:boolean {
  if (matches(lower-case($node/*:source[1]),$regex) or matches(lower-case($node/*:publisher-name[1]),$regex))
    then true()
  else false()
};

let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[*:body and //*:element-citation[@publication-type="software"]]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    return <item id="{$id}" pub-year="{$pub-year}" base="{$b}">{
     for $y in $x//*:element-citation[@publication-type="software"]
     return $y
    }</item>
    }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 

for $year in distinct-values($list//*:item/@pub-year)
let $refs := $list//*:item[@pub-year=$year]//*:element-citation
let $github := count(for $x in $refs where local:match($x,'github') return $x)
let $osf := count(for $x in $refs where local:match($x,'osf') return $x)
let $swh := count(for $x in $refs where local:match($x,'software heritage') return $x)
let $figtree := count(for $x in $refs where local:match($x,'figtree') return $x)
let $bitbucket := count(for $x in $refs where local:match($x,'bitbucket') return $x)
let $gitlab := count(for $x in $refs where local:match($x,'gitlab') return $x)
let $cran := count(for $x in $refs where local:match($x,'cran') return $x)
let $figshare := count(for $x in $refs where local:match($x,'figshare') return $x)
let $zenodo := count(for $x in $refs where local:match($x,'zenodo') return $x)
let $sourceforge := count(for $x in $refs where local:match($x,'sourceforge') return $x)
let $docker := count(for $x in $refs where local:match($x,'docker') return $x)
order by $year
return $year||'	'||count($refs)||'	'||$github||'	'||$osf||'	'||$swh||'	'||$figtree||'	'||$bitbucket||'	'||$gitlab||'	'||$cran||'	'||$figshare||'	'||$zenodo||'	'||$sourceforge||'	'||$docker
