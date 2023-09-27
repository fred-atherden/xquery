let $pre-folder := '/Users/fredatherden/Desktop/pre-edit'
let $pre-files := file:list($pre-folder, true(), '*.xml')
let $pub-folder := '/Users/fredatherden/Desktop/pub'

for $z in $pre-files
  let $article := doc($pre-folder||'/'||$z)
  let $pub-article := if (file:exists($pub-folder||'/'||$z)) then doc($pub-folder||'/'||$z)
                      else ()
  
  return if (matches($article,'copy archived at')) then $z
    else if (matches($pub-article,'copy archived at')) then $z
    else()