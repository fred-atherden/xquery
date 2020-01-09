distinct-values(
  for $x in collection('articles')//*:article
  let $authors := $x//*:article-meta//*:contrib-group[not(@*)]
  let $count := count($authors/*:contrib)
  let $eq-count := count($authors/*:contrib[@equal-contrib='yes'])
  let $auth1 := $authors/*:contrib[1]
  let $auth2 := $authors/*:contrib[2]
  let $auth3 := $authors/*:contrib[3]
  let $auth4 := $authors/*:contrib[4]
  return
  if ($count < 3) then () 
  else if ($auth1[@equal-contrib='yes'] and $auth2[@equal-contrib='yes'] and $auth3[@equal-contrib='yes']) then substring-before($x/base-uri(),'-v')
  else ()
)