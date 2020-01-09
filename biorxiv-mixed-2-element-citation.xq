declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";

declare variable $filename := 'xsl-test.xml';
declare variable $dir := '/Users/fredatherden/Desktop/';
declare variable $xsl := doc('/Users/fredatherden/Documents/xsl/mixed-2-element-citation.xsl');



for $x in collection('biorxiv-xml')//*:article[base-uri() = '/biorxiv-xml/686329.xml']
let $file := xslt:transform($x, $xsl)
return file:write(concat($dir,$filename),$file, map {'indent':'no'})

