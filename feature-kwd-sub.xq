for $x in collection('articles')//*:article
let $type := $x//*:subj-group[@subj-group-type="display-channel"]/*:subject/lower-case(.)
let $sub := $x//*:subj-group[@subj-group-type="sub-display-channel"]/*:subject/lower-case(.)
let $kwds := $x//*:kwd-group[@kwd-group-type="author-keywords"]
return
if ($type = ('feature article', 'insight')) then (
    let $match := for $x in $kwds/*:kwd
                  return if (lower-case($x) = $sub) then $x
                  else ()
    return
    if (matches($match,'[a-z]')) then concat($x/base-uri(),' ------ ',$match)
    else ()
  )
else ()