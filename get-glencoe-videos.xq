let $id := '69786'
let $uri := 'https://movie-usa.glencoesoftware.com/metadata/10.7554/eLife.'||$id
let $json := json:parse(fetch:text($uri))
let $folder := '/Users/fredatherden/Desktop/videos/'

return (
  if (file:is-dir($folder)) then ()
  else file:create-dir($folder)
   ,
    for $x in $json//mp4__href/string()
    let $name := tokenize($x,'/')[last()]
    let $file := fetch:binary($x)
    return file:write(($folder||$name),$file) 
)