let $folder := '/Users/fredatherden/Desktop/resupplies/'
let $updated := ($folder||'updated/')

for $file in file:list($folder)[ends-with(.,'.zip')]
let $no := substring-before(substring-after($file,'elife-'),'-')
let $zip := file:read-binary($folder||$file)
let $xml-entry := archive:entries($zip)[matches(.,'^elife-\d{5}-v\d\.xml$')]
let $new-xml := copy $copy := fn:parse-xml(archive:extract-text($zip,$xml-entry))
                modify(
                  let $vals := ('competing-interest','author-contribution','ethics-information')
                  for $x in $copy//*:fn-group[not(@content-type=$vals)]
                  return delete node $x
                )
                return $copy
let $temp-xml-loc := ($folder||'pdfs/'||$xml-entry/text())
return (
  file:write($temp-xml-loc,
             $new-xml,
             map {'indent':'no',
                  'omit-xml-declaration':'no',
                  'doctype-system':'JATS-archivearticle1-mathml3.dtd',
                  'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD with MathML3 v1.2 20190208//EN'}
                 ),
 let $updated-zip := archive:update($zip,$xml-entry,file:read-binary($temp-xml-loc))
 return (
   file:write-binary(($updated||$file),$updated-zip),
   file:delete($temp-xml-loc))
)