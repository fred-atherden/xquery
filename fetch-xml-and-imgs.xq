let $art-no := '72666'
let $folder := '/Users/fredatherden/Desktop/eras/'||$art-no||'/'
let $json := json:parse(fetch:text('https://api.elifesciences.org/articles/'||$art-no))
let $xml := $json/*/*:xml

return (
  if (file:is-dir($folder)) then ()
  else file:create-dir($folder),
  
  if (file:is-dir($folder||'/elife-'||$art-no||'.xml.media/')) then ()
  else file:create-dir($folder||'/elife-'||$art-no||'.xml.media/'),
  
  for $x in $json//*:image
  let $filename := $x/*:source/*:filename
  let $uri := $x/*:source/*:uri
  return file:write-binary(($folder||'/elife-'||$art-no||'.xml.media/'||$filename),fetch:binary($uri)),
  
  let $article := parse-xml(fetch:text($xml))
  let $new-xml := copy $copy := $article
                  modify(
                    for $g in $copy//*:graphic
                    let $uri := $g/@*:href
                    let $new-uri := 'elife-'||$art-no||'.xml.media/'||substring-before($uri,'.tif')||'.jpg'
                    return replace value of node $g/@*:href with $new-uri
                  )
                  return $copy
  return file:write(($folder||'elife-'||$art-no||'.xml'),$new-xml, map {'indent':'no',
                   'omit-xml-declaration':'no',
                   'doctype-system':'JATS-archivearticle1-mathml3.dtd',
                   'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD with MathML3 v1.2 20190208//EN'})
)