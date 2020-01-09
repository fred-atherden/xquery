distinct-values(for $x in collection('pmc')//*:article//*:article-id
let $t := $x/@pub-id-type
return
if ($t = 'pmc') then ()
else if ($t = 'pmid') then ()
else if ($t = 'publisher-id') then ()
else if ($t = 'doi') then ()
else $t
)