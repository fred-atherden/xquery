let $xml := doc('/Users/fredatherden/Desktop/elife-66031-vor-r3/elife-66031.xml')

for $x in $xml//*:contrib-group[@content-type="authors"]/*:contrib
let $con-ref := $x/*:xref[matches(@rid,'^con\d+$')]/@rid
let $con := $x/ancestor::*:article//*:fn[@id=$con-ref]
let $new-cons := for $x in analyze-string($con,'Conceptuali[zs]ation|Data curation|Formal analysis|Funding acquisition|Investigation|Methodology|Project administration|Resources|Software|Supervision|Validation|Visualization|Writing\s?[—––\-]\s?original draft|Writing\s?[—––\-]\s?review (&amp;|and) editing')/*
                 return 
                 if ($x/local-name()="match") then 
                   if (contains($x,'review')) then (
                     <role vocab="credit" vocab-identifier="http://credit.niso.org/" 
                          vocab-term="Writing – review &amp; editing"
                          vocab-term-identifier="http://credit.niso.org/contributor-roles/writing-review-editing/">{$x/text()}</role>)
                   else if (contains($x,'original')) then (
                     <role vocab="credit" vocab-identifier="http://credit.niso.org/" 
                          vocab-term="Writing – original draft"
                          vocab-term-identifier="http://credit.niso.org/contributor-roles/writing-original-draft/">{$x/text()}</role>)
                   else (
                    <role vocab="credit" vocab-identifier="http://credit.niso.org/" 
                          vocab-term="{$x/text()}"
                          vocab-term-identifier="{('http://credit.niso.org/contributor-roles/'||
                        replace(lower-case($x),'\s','-'))}">{$x/text()}</role>)
                        
                 else if (replace($x,'[\s,]','')="") then ()
                 else <role>{replace($x/text(),'^\s?,?\s','')}</role>
return (data($x/*:name/*:surname),$new-cons)