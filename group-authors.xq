distinct-values(for $x in collection('articles')//*:article
                let $m := $x//*:article-meta
                let $id:= $x//*:article-id[@pub-id-type="publisher-id"]
                return
                  for $y in $m//*:contrib
                  return
                if (matches($y,'[Rr]eproducibility [Pp]roject')) then ()
                else if ($y/*:collab) then $id
                else if ($y//*:contrib) then $id
                else ()
                )