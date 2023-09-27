let $eras := distinct-values(for $x in collection('era')//*:article return $x/@id)

let $pre-folder := '/Users/fredatherden/Desktop/pre-edit'
let $pre-files := file:list($pre-folder, true(), '*.xml')
for $z in $pre-files
  let $article := doc($pre-folder||'/'||$z)
  let $no := $article//*:article-meta/*:article-id[@pub-id-type="publisher-id"]/data()
  where not($no=$eras)
  return 
  if ($article//*:ext-link[contains(@*:href,'softwareheritage')]) then (($z||' software heritage'),<article id="{$no}" status="contacted/ignored"/>)
  else if ($article//*:supplementary-material/*:caption[matches(lower-case(.),'r\s?markdown|jupyter|notebook|python')]) then 
   (($z||' file'),<article id="{$no}" status="contacted/ignored"/>)
  else if ($article//*:ext-link[matches(@*:href,'github|gitlab')]) then (($z||' '||string-join(distinct-values(for $y in $article//*:ext-link[matches(@*:href,'github|gitlab')] return analyze-string($y,'github|gitlab')//*:match),'; ')),<article id="{$no}" status="contacted/ignored"/>)
  else ()