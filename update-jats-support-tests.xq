let $path := '/Users/fredatherden/Documents/GitHub/jats-support-2/tests/cases/contrib-group'

for $x in file:list($path)
let $doc := doc($path||'/'||$x)
let $new-doc := copy $copy := $doc
modify(
  for $root in $copy/*[1]
  return
  insert node (processing-instruction {'expected-error'}{('message="'||'<contrib-group> in <> is ignored."'||' node="'||'/contrib-group"')},'&#xa;','&#xa;')  before $root
)
return $copy

return file:write(($path||'/'||$x),$new-doc)