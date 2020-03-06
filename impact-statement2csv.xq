let $pre-folder := '/Users/fredatherden/Desktop/pre-edit'
let $pre-files := file:list($pre-folder, true(), '*.xml')
 
let $csv := <csv>{
  for $z in $pre-files
  let $id := substring-before(substring-after($z,'elife-'),'.xml')
  let $article := doc($pre-folder||'/'||$z)
  let $i := $article//*:custom-meta[@specific-use="meta-only" and *:meta-name='Author impact statement']/*:meta-value[1]
  return
  <record><entry>{$id}</entry><entry>{serialize($i/(*|text()))}</entry></record>
}</csv> 

return file:write('/Users/fredatherden/Desktop/impact-statements.csv',$csv,map{'method':'csv'})
 