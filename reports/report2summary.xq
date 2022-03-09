let $pre-report := doc('/Users/fredatherden/Desktop/pre-edit/pre-report.xml')

let $ignore := ('test-r-article-a-reply','fig-test-6','back-test-8','dec-letter-front-test-4','das-supplemental-conformity','dec-letter-editor-test-2','article-title-test-11','pre-test-r-article-d-letter','pre-pub-date-test-1','pre-pub-date-test-2','auth-cont-test-1','fig-id-test-4','feature-template-test-4','feature-template-test-3')

let $prod-query := ('colour-check-table','custom-meta-test-8','vid-xref-test-4','colour-named-content-check','award-id-test-1','data-harvard-dataverse-test-2','ra-sec-test-4','fig-video-check-1','reproduce-test-3','custom-meta-test-7','fig-data-test-1','reproduce-test-1','custom-meta-test-13','table-xref-test-1','feat-fig-test-3','head-subj-test3','feat-fig-specific-test-4','das-request-conformity-1','rep-study-custom-meta-test','COI-test','kr-table-not-tagged-2','article-title-test-10','funding-group-test-2','ra-sec-test-3','reproduce-test-5','reproduce-test-4','sec-conformity','sec-type-title-test','supplementary-material-test-10','das-elem-cit-4','reproduce-test-6','kr-table-header-8','funding-group-test-3','kr-table-header-1','reproduce-test-2','reproduce-test-7','sec-test-4','reproduce-test-8','author-id-1')

let $auth-query := ('supplementary-material-test-2','missing-ref-in-text-test','fig-xref-test-4','fig-title-test-1','fig-title-test-5','body-video-position-test-1','pubmed-presence','collab-cont-test-1','ref-software-test-5','pre-award-group-test-7','fig-title-test-6','named-content-type-check','fig-title-test-8','supplementary-material-title-test-8','table-title-test-6','video-title-test-8','table-title-test-5','fig-specific-test-7','inline-formula-length-test-1')

let $unsure := ('fig-caption-test-1','auth-kwd-check','all-caps-surname','err-elem-cit-data-13-2','ref-xref-test-14','err-elem-cit-data-13-2','empty-parentheses-presence','supplementary-material-title-test-1','inline-formula-test-3','p-test-6','err-elem-cit-high-6-2','given-names-count-2','supp-file-xref-test-1','tr-test-2','p-bracket-test','p-punctuation-test','surname-test-5','supplementalfigure-presence','author-test-3','article-title-correction-check','supplementalfile-presence','ack-full-stop-intial-test','Inc-presence','fig-specific-test-3','duplicate-ref-test-4','table-test-2','equ-xref-conformity-2','equ-xref-conformity-1','article-title-test-2','video-title-test-1','feat-table-wrap-cite-1','warning-elem-cit-book-13-3','err-elem-cit-web-10-1','ref-xref-test-18','sec-test-3','book-doi-test-1','journal-doi-test-1','ref-xref-test-11','author-test-2','ref-xref-test-15','ref-xref-test-17','media-test-4','fig-xref-conformity-3','cell-spacing-test','inline-formula-test-2','conf-doi-test-1','article-title-journal-check','math-test-8','software-doi-test-1','journal-conference-ref-check-1','ext-link-child-test-5','ref-xref-test-13','ref-xref-test-12','text-v-object-cite-test','order-test-1','xref-column-test','eloc-page-assert','volume-assert','err-elem-cit-book-13-1','book-chapter-test-2','award-group-test-3','award-group-test-7','code-fork-info','institution-id-test','custom-meta-test-11','list-item-test-1','supplement-table-presence','supplementaryfigure-presence','fig-title-test-7','supplementary-material-title-test-7','math-test-15','kr-table-first-column-1','github-no-citation','gitlab-no-citation','fig-caption-test-3')


let $report := copy $copy := $pre-report
      modify(
        for $m in $copy//*:item/*[@role=('error','warning')]
        let $id := $m/@id
        let $loc := $m/@location
        return
        if ($id=$ignore) then ()
        else if ($m/@escape) then ()
        else if (contains($loc,'sub-article') and not($id='dec-letter-front-test-2')) then ()
        else if (ends-with($id,'-italic-test')) then insert node attribute {'action'} {'fix'} as last into $m
        else if ($id=$auth-query) then ()
        else if (not($id='pre-ref-xref-test-1') and starts-with($id,'pre-')) then ()
        else if ($id=$prod-query) then ()
        else if ($id=$unsure) then ()
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