distinct-values(for $x in collection('articles')//*:article//*:funding-group//*:award-group[descendant::*:institution = 'Seventh Framework Programme']
return $x//*:institution-id/text())