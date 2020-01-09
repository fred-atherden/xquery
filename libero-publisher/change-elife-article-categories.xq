declare variable $outputDir := '/Users/fredatherden/Desktop/categories/';

for $x in collection('articles')//*:article
let $filename := substring-after($x/base-uri(),'articles/')
let $new := 
copy $copy := $x
modify(
  for $y in $copy//*:article-meta//*:subj-group[@subj-group-type="heading"]/@subj-group-type
  return
  replace value of node $y with 'subject',
  
  for $d in $copy//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/@subj-group-type
  return
  replace value of node $d with 'heading'
)
return $copy

return file:write(concat($outputDir,$filename),$new,map{'indent':'no'})
