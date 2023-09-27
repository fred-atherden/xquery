declare function local:non-distinct-values
  ($seq as xs:anyAtomicType*) as xs:anyAtomicType* {
    for $val in distinct-values($seq)
    return $val[count($seq[. = $val]) > 1]
 };

let $insights := distinct-values(
    for $x in collection('articles')//*:article[@article-type="article-commentary"]
    let $link := $x//*:article-meta/*:related-article/@*:href
    order by $x/base-uri() descending
    return $link
  )

let $corrections := distinct-values(
    for $x in collection('articles')//*:article[@article-type="correction"]
    let $link := $x//*:article-meta/*:related-article/@*:href
    order by $x/base-uri() descending
    return $link)

return local:non-distinct-values(($insights,$corrections))