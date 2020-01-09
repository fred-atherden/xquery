  for $x in collection('articles')//*:article[*:body and descendant::*:article-meta/*:contrib-group//*:collab]
  let $base := $x/base-uri()
  let $version := replace(substring-before(substring-after($base,'/articles/elife-'),'.xml'),'-','')
  let $cmd := ('encoda convert https://elifesciences.org/articles/'||$version||' encoda-test/'||$version||'.xml --to jats')
  return 
  $cmd