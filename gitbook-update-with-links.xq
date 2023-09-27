let $page := 'https://elifesciences.gitbook.io/productionhowto/-M1eY9ikxECYR-0OcnGt/article-details/content/article-structure'
let $ids := ('sec-title-list-check', 'sec-title-appendix-check', 'sec-title-appendix-check-2', 'sec-title-abbr-check', 'sec-title-content-mandate', 'sec-title-full-stop', 'sec-title-bold	', 'sec-title-underline', 'sec-title-italic', 'sec-title-dna	', 'sec-title-rna', 'sec-title-dimension', 'sec-title-hiv	', 'section-title-test-1', 'sec-conformity', 'ra-sec-test-1', 'ra-sec-test-2', 'ra-sec-test-3', 'ra-sec-test-4', 'sec-type-title-test', 'body-top-level-sec-id-test', 'low-level-sec-id-test', 'sec-test-1', 'sec-test-2')

let $s := doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/schematron.sch')

let $sch := 
copy $copy := $s
modify(
  for $x in $copy//(*:report[@id=$ids]|*:assert[@id=$ids])
  let $url := ($page||'#'||$x/@id)
  return insert node attribute see {$url} into $x
)
return $copy

return $sch