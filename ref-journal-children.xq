distinct-values(for $x in collection('articles')//*:element-citation[@publication-type="journal"]
return $x/*/local-name())