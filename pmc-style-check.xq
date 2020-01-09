declare variable $xsl := doc('/Users/fredatherden/Documents/pmc-style-check/nlm-style-5.23/nlm-stylechecker.xsl');

for $x in collection('articles')//*:article[not(descendant::subj-group[@subj-group-type="heading"])]
let $output :=  xslt:transform($x,$xsl)
let $errors := <list>{for $y in $output//*:error
               return $y}</list>
               
return $errors