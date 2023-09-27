let $list := 

<list>
    <item>eloc-page-assert</item>
    <item>volume-assert</item>
    <item>online-journal-w-page</item>
    <item>journal-doi-test-1</item>
    <item>err-elem-cit-journal-6-5-2</item>
    <item>err-elem-cit-journal-6-6</item>
    <item>err-elem-cit-journal-13</item>
    <item>err-elem-cit-journal-10</item>
    <item>ref-article-title-check</item>
    <item>PLOS-1</item>
    <item>PLOS-2</item>
    <item>PNAS</item>
    <item>RNA</item>
    <item>bmj</item>
    <item>G3</item>
    <item>ampersand-check</item>
    <item>Research-gate-check</item>
    <item>Please provide the journal name for this reference.</item>
    <item>journal-replacement-character-presence</item>
    <item>journal-off-presence</item>
    <item>handbook-presence</item>
    <item>article-title-fullstop-check-1</item>
    <item>article-title-fullstop-check-2</item>
    <item>article-title-fullstop-check-3</item>
    <item>article-title-correction-check</item>
    <item>article-title-journal-check</item>
    <item>article-title-child-1</item>
    <item>a-title-replacement-character-presence</item>
    <item>journal-preprint-check</item>
    <item>elife-ref-check</item>
    <item>journal-conference-ref-check-1</item>
    <item>journal-conference-ref-check-2</item>
    <item>err-elem-cit-journal-2-1</item>
    <item>err-elem-cit-journal-2-2</item>
    <item>err-elem-cit-journal-3-1</item>
    <item>err-elem-cit-journal-4-1</item>
    <item>err-elem-cit-journal-4-2-2</item>
    <item>err-elem-cit-journal-5-1-3</item>
    <item>err-elem-cit-journal-12</item>
    <item>err-elem-cit-journal-3-2</item>
    <item>err-elem-cit-journal-5-1-2</item>
    <item>err-elem-cit-journal-6-3</item>
    <item>err-elem-cit-journal-6-4</item>
    <item>err-elem-cit-journal-6-5-1</item>
    <item>err-elem-cit-journal-6-7</item>
    <item>err-elem-cit-journal-9-1</item>
</list>

let $src := '/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/'
let $schema := doc($src||'schematron.sch')

let $list := <list xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/" xmlns:file="java.io.File" xmlns:java="http://www.java.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">{
for $test in $schema//(*:report|*:assert)
return
if ($test/@id = $list//*:item/text()) then (
  let $new := 
    copy $copy := $test
    modify(
      let $text := (' More information here - https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/journal-references#'||$copy/@id)
      return insert node $text as last into $copy
)
return $copy

return $new)
else ()
}</list>

return $list