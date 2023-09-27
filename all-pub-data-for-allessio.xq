let $list1 := 
<list>{
 for $x in collection('articles')//*:article[@article-type=("research-article")]
 let $subj := $x//*:article-categories//*[@subj-group-type="display-channel"]/*/data()
 where not(lower-case($subj)=('feature article','replication study'))
 let $pub := $x//*:article-meta/*:pub-date[@publication-format="electronic"][1]
 let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
 let $pub-date := $pub-year||'-'||$pub/*:month[1]||'-'||$pub/*:day[1]
 let $b := $x/base-uri()
 let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
 let $msas := string-join($x//*:article-categories//*[@subj-group-type="heading"]/*,'; ')
 let $type := if ($x/*:body) then 'version of record' else 'publish on accept'
 order by $b
 return <item type="{$type}" pub-year="{$pub-year}" pub-date="{$pub-date}" id="{$id}" msas="{$msas}">{$b}</item>
}</list>

let $list2 := 
<list>{
  for $x in $list1/*:item
  let $id := $x/@id/string()
  return
  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
  else $x
}</list>

let $list := 
  let $rp-json := json:parse(file:read-text('/Users/fredatherden/Documents/GitHub/enhanced-preprints-client/manuscripts.json'))
  return <list>{(
    $list2//*:item,
    for $rp in $rp-json//*:preprints/*
    let $preprint-doi := $rp/*:preprintDoi/data()
    let $id := $rp-json//*:manuscripts/*[preprintDoi=$preprint-doi][1]/*:msid
    where not($list2//*:item/@id=$id)
    let $date := $rp/*:status/*:timeline/_[*:name='Reviewed Preprint posted']/date/data()
    let $pub-year := tokenize($date,'-')[1]
    let $msas := string-join($rp/msas/_,'; ')
    return <item type="reviewed preprint" pub-year="{$pub-year}" pub-date="{$date}" id="{$id}" msas="{$msas}"/>
  )}</list>

let $csv := <csv>
<record>
<entry>publication type</entry>
<entry>DOI</entry>
<entry>pub year</entry>
<entry>pub date</entry>
<entry>MSAs</entry>
</record>
{
for $year in distinct-values($list//*:item/@pub-year)
let $items := $list//*:item[@pub-year=$year]
for $item in $items
order by $item/@pub-date
return 
<record>
<entry>{$item/@type/string()}</entry>
<entry>{'https://doi.org/10.7554/eLife.'||$item/@id}</entry>
<entry>{$item/@pub-year/string()}</entry>
<entry>{$item/@pub-date/string()}</entry>
<entry>{$item/@msas/string()}</entry>
</record>
}</csv>

return file:write('/Users/fredatherden/Desktop/article-data.csv',$csv,map{'method':'csv','encoding':'UTF-8'})