(: has to be captured as an xml file to retain the curly braces in regex :)
let $credit := doc('/Users/fredatherden/Documents/GitHub/xquery/ejp/credit-list.xml')

let $list := 
  let $temp-list :=  <list>{
    for $x in collection('articles')//*:article[@article-type="research-article" and *:body]
    let $pub-year := $x//*:article-meta/*:pub-date[@date-type=("publication","pub")][1]/*:year[1]/string()
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    let $cons := <list>{
                  for $y in $x//*:fn-group[@content-type="author-contribution"]//*:fn
                  let $auth-count := count($y/ancestor::*:article//*:article-meta//*:contrib[@contrib-type="author" and *:xref[@rid = $y/@id]])
                  return <item auth-count="{$auth-count}">{$y}</item>
                 }</list>
    order by $b
    return 
    <item id="{$id}" pub-year="{$pub-year}" base="{$b}">{
      for $z in $credit//*:item
      let $matches := $cons//*:item[matches(lower-case(.),$z/@regex)]
      let $count := sum($matches/@auth-count)
      return <item name="{$z/@name}" auth-count="{$count}">{$matches}</item>
    }</item>
  }</list>
  return <list>{
    for $x in $temp-list/*:item
    let $id := $x/@id/string()
    where not($x/following-sibling::*:item[@id=$id])
    return $x
  }</list> 
  
for $year in distinct-values($list//*:item/@pub-year)
let $items := $list/*:item[@pub-year=$year]
let $c := sum($items/*:item[@name="Conceptualization"]/@auth-count)
let $dc := sum($items/*:item[@name="Data curation"]/@auth-count)
let $fo := sum($items/*:item[@name="Formal analysis"]/@auth-count)
let $fu := sum($items/*:item[@name="Funding acquisition"]/@auth-count)
let $i := sum($items/*:item[@name="Investigation"]/@auth-count)
let $m := sum($items/*:item[@name="Methodology"]/@auth-count)
let $pa := sum($items/*:item[@name="Project administration"]/@auth-count)
let $r := sum($items/*:item[@name="Resources"]/@auth-count)
let $so := sum($items/*:item[@name="Software"]/@auth-count)
let $su := sum($items/*:item[@name="Supervision"]/@auth-count)
let $va := sum($items/*:item[@name="Validation"]/@auth-count)
let $vi := sum($items/*:item[@name="Visualization"]/@auth-count)
let $wo := sum($items/*:item[@name="Writing-od"]/@auth-count)
let $wr := sum($items/*:item[@name="Writing-re"]/@auth-count)
let $values := ($c,$dc,$fo,$fu,$i,$m,$pa,$r,$so,$su,$va,$vi,$wo,$wr)

return $year||'	'||count($items)||'	'||string-join($values,'	')