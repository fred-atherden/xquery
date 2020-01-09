let $xsl := doc('/Users/fredatherden/Documents/xsl/jats2rdf.xsl')

for $x in collection('ijm-xml')//*:article
let $t := xslt:transform($x,$xsl)
let $name :=  for $y in tokenize($x/base-uri(),'/')[last()]
              return $y

return file:write(concat('/Users/fredatherden/Desktop/output/',$name),$t)