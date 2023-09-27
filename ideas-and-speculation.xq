distinct-values(
  for $x in collection('articles')//*:article//*:sec[lower-case(*:title)='ideas and speculation']
  let $doi := $x/ancestor::*:article//*:article-meta/*:article-id[@pub-id-type="doi"]
  order by $doi descending 
  return 'https://elifesciences.org/articles/'||substring-after($doi,'ife.')||'#'||$x/@id
)