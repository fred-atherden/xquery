declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace mml="http://www.w3.org/1998/Math/MathML";


declare variable $dir := '/Users/fredatherden/Desktop/biorxiv-tranformed/';
declare variable $xsl := doc('/Users/fredatherden/Documents/xsl/mixed-2-element-citation.xsl');



for $x in collection('biorxiv-xml')//*:article
let $filename := concat(substring-after($x//*:article-meta/*:article-id[@pub-id-type="doi"],'10.1101/'),'.xml')
let $file := xslt:transform($x, $xsl)
return file:write(concat($dir,$filename),$file, map {'indent':'no'})

