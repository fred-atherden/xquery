let $path := '/Users/fredatherden/Documents/GitHub/reference-manuscripts/manuscripts'

for $x in file:list($path)[.!='.DS_Store']
let $files := file:list($path||'/'||$x)[.!='.DS_Store']
let $xml-path := ($path||'/'||$x||'/'||$files[not(contains(.,'manifest')) and ends-with(.,'.xml')])
let $xml := doc($xml-path)
let $new-xml := copy $copy := $xml
modify(
  for $date in $copy//*:article-meta/*:pub-date[@date-type="publication" and @publication-format="electronic"]
  return replace value of node $date/@date-type with "pub"
)
return $copy
return file:write($xml-path,
                  $xml,
                  map {'indent':'no',
                   'omit-xml-declaration':'no',
                   'doctype-system':'JATS-archivearticle1.dtd',
                   'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN'}
                 )