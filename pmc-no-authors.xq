let $list := <list>{

  for $x in (
    collection('pmc1')//*:article-meta[not(descendant::*:contrib[@contrib-type="author"])],
    collection('pmc2')//*:article-meta[not(descendant::*:contrib[@contrib-type="author"])],
    collection('pmc3')//*:article-meta[not(descendant::*:contrib[@contrib-type="author"])]
  )
  let $url := ('https://www.ncbi.nlm.nih.gov/pmc/articles/PMC'||$x/article-id[@pub-id-type="pmc"]||'/')
  return <item publisher="{$x/preceding-sibling::*:journal-meta//*:publisher-name}">{$url}</item>

}</list>

for $x in distinct-values($list//*:item/@publisher)
let $count := count($list//*:item[@publisher = $x])
return ($x||' --- '||$count)