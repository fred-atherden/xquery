let $path := '/Users/fredatherden/Desktop/IJM'
let $output := '/Users/fredatherden/Desktop/hive/'
let $files := file:list($path)[ends-with(.,'.xml') and not(starts-with(.,'._'))]

for $file in $files
let $xml := doc($path||'/'||$file)
let $dtd-version := $xml//*:article/@dtd-version
let $xsl := doc('/Users/fredatherden/Documents/xsl/ijm2hive.xsl')
let $hive-xml := xslt:transform($xml,$xsl)

return if ($dtd-version = '1.2') then (file:write(($output||$file),$hive-xml, map {'indent':'no',
                  'omit-xml-declaration':'no',
                  'doctype-system':'JATS-archivearticle1-mathml3.dtd',
                  'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.2 20190208//EN'})
  
)

else (file:write(($output||$file),$hive-xml, map {'indent':'no',
                  'omit-xml-declaration':'no',
                  'doctype-system':'JATS-archivearticle1-mathml3.dtd',
                  'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN'})
)