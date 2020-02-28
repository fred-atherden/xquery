let $name := 'elife-45413'
let $file := ('/Users/fredatherden/Desktop/'||$name||'.xml')
let $xml := doc($file)
let $xsl := doc('/Users/fredatherden/Documents/GitHub/mml2tex/xsl/invoke-mml2tex.xsl')
let $new-xml := xslt:transform($xml,$xsl)

let $new-new-xml := 
copy $copy := $new-xml
modify(
  for $x in $copy//*:inline-formula/processing-instruction('mml2tex')
  return replace node $x with <tex-math>{data($x)}</tex-math>,
  
  for $x in $copy//*:display-formula/processing-instruction('mml2tex')
  return replace node $x with <tex-math>{data($x)}</tex-math>
)
return $copy

return file:write(
          ('/Users/fredatherden/Desktop/'||$name||'-test.xml'),
          $new-new-xml,
           map {'indent':'no',
                   'omit-xml-declaration':'no',
                   'doctype-system':'JATS-archivearticle1.dtd',
                   'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN',
                   'cdata-section-elements':'tex-math'}
                 )