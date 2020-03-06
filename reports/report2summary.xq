let $pre-report := doc('/Users/fredatherden/Desktop/pre-edit/pre-report.xml')

let $ignore := ('test-r-article-a-reply','code-fork-info','fig-test-6','institution-id-test','back-test-8','dec-letter-front-test-4','das-supplemental-conformity','dec-letter-editor-test-2','article-title-test-11','pre-test-r-article-d-letter','pre-pub-date-test-1','pre-pub-date-test-2','auth-cont-test-1','fig-id-test-4')

let $prod-query := ('colour-check-table','custom-meta-test-8','vid-xref-test-4','colour-named-content-check','award-id-test-1','data-harvard-dataverse-test-2','ra-sec-test-4','fig-video-check-1','reproduce-test-3','custom-meta-test-7','fig-data-test-1','reproduce-test-1','custom-meta-test-13','table-xref-test-1','feat-fig-test-3','head-subj-test3','feat-fig-specific-test-4','das-request-conformity-1','rep-study-custom-meta-test','COI-test','kr-table-not-tagged-2','article-title-test-10','funding-group-test-2')

let $auth-query := ('supplementary-material-test-2','missing-ref-in-text-test','fig-xref-test-4','fig-title-test-1','fig-title-test-5','body-video-position-test-1','text-v-cite-test')

let $unsure := ('fig-caption-test-1','auth-kwd-check','all-caps-surname','err-elem-cit-data-13-2','ref-xref-test-14','err-elem-cit-data-13-2','empty-parentheses-presence','supplementary-material-title-test-1','inline-formula-test-3','p-test-6','err-elem-cit-high-6-2','given-names-count-2','supp-file-xref-test-1','tr-test-2','p-bracket-test','p-punctuation-test','surname-test-5','supplementalfigure-presence','author-test-3','article-title-correction-check','supplementalfile-presence','ack-full-stop-intial-test','Inc-presence','fig-specific-test-3','duplicate-ref-test-4','table-test-2','equ-xref-conformity-2','equ-xref-conformity-1','article-title-test-2','video-title-test-1','feat-table-wrap-cite-1','warning-elem-cit-book-13-3','err-elem-cit-web-10-1','ref-xref-test-18','sec-test-3','book-doi-test-1','journal-doi-test-1','ref-xref-test-11','author-test-2','ref-xref-test-15','ref-xref-test-17','media-test-4','fig-xref-conformity-3','cell-spacing-test')

let $report := copy $copy := $pre-report
      modify(
        for $m in $copy//*:item/*[@role=('error','warning')]
        let $id := $m/@id
        let $loc := $m/@location
        return
        if ($id=$ignore) then ()
        else if (contains($loc,'sub-article')) then ()
        else if (ends-with($id,'-italic-test')) then insert node attribute {'action'} {'fix'} as last into $m
        else if ($id=$auth-query) then ()
        else if (starts-with($id,'pre-')) then ()
        else if ($id=$prod-query) then ()
        else if ($id=$unsure) then ()
        else if ($m/@escape) then ()
        else insert node attribute {'action'} {'fix'} as last into $m
      )
 return $copy

let $total := count($report//*:item)
let $invalid-total := count($report//*:item[not(@escape) and child::*[not(@escape) and @role="error"]])
let $fix-total := count($report//*:item[not(@escape) and descendant::*[@action="fix"]])
let $per := $fix-total div $total * 100
let $fixes := count($report//*:item[not(@escape)]//*[@action="fix"])
let $values := for $a in $report//*:item[not(@escape)] return count($a/*[@action="fix"])
let $list := for $y in $values order by number($y) return $y
let $count := count($list)
let $median-number :=  
    if (($count mod 2)=1) then (($count div 2)+0.5)
    else (($count div 2),(($count div 2)+1))

let $median := 
    if (count($median-number)=1) then (for $x in $list[position()=$median-number] return $x)
    else (sum(for $x in $list[position()=$median-number] return $x) div 2)

return (
  $total||
  '	'||
  $invalid-total||
  '	'||
  $fix-total||
  '	'||
  $per||
  '	'||
  $fixes||
  '	'||
  string-join($list,', ')||
  '	'||
  $median
)