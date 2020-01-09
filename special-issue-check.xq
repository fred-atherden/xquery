distinct-values(
  for $x in collection('articles')//*:article[*:body]//*:article-meta//(*:article-title|*:kwd)
  let $l := lower-case($x)
  let $doi := $x/ancestor::*:article-meta/*:article-id[@pub-id-type="doi"]
  return
  if (matches($l,' aging| ageing| longevity| lifespan| geroscience|^aging|^ageing|^longevity|^lifespan|^geroscience')) then ('- http://doi.org/'||$doi)
  else ()
)