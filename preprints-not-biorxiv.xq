distinct-values(
  for $x in collection('articles')//*:article[//*:article-meta//*:pub-history]
  let $pre := $x//*:article-meta//*:pub-history/*:event/*:self-uri/@*:href
  where not(matches($pre,'doi.org/10\.1101'))
  let $b := $x/base-uri()
  let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
  order by number($id) descending
  return $id||' '||$pre
)