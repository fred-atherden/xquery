declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";


declare variable $dir := '/Users/fredatherden/Desktop/untitled-folder/';
declare variable $xsl := doc('/Users/fredatherden/Documents/xsl/biorxiv2hive.xsl');

let $files := file:list($dir)[ends-with(.,'.xml')]

for $file in $files
let $xml := doc($dir||$file)
let $hive-xml := xslt:transform($xml,$xsl)

return file:write(concat($dir,$file),$hive-xml, map {'indent':'no',
                  'omit-xml-declaration':'no',
                  'doctype-system':'JATS-archivearticle1.dtd',
                  'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.2d1 20170631//EN'})

