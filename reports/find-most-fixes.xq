let $pre-report := doc('/Users/fredatherden/Desktop/pre-edit/pre-report.xml')

let $ignore := ('test-r-article-a-reply','code-fork-info','fig-test-6','institution-id-test','back-test-8','dec-letter-front-test-4','das-supplemental-conformity','dec-letter-editor-test-2','article-title-test-11','pre-test-r-article-d-letter','pre-pub-date-test-1','pre-pub-date-test-2','auth-cont-test-1','fig-id-test-4')

let $prod-query := ('colour-check-table','custom-meta-test-8','vid-xref-test-4','colour-named-content-check','award-id-test-1','data-harvard-dataverse-test-2','ra-sec-test-4','fig-video-check-1','reproduce-test-3','custom-meta-test-7','fig-data-test-1','reproduce-test-1')

let $auth-query := ('supplementary-material-test-2','missing-ref-in-text-test','fig-xref-test-4','fig-title-test-1','fig-title-test-5','body-video-position-test-1')

let $unsure := ('fig-caption-test-1','auth-kwd-check','all-caps-surname','err-elem-cit-data-13-2','ref-xref-test-14','err-elem-cit-data-13-2','empty-parentheses-presence','supplementary-material-title-test-1','inline-formula-test-3','p-test-6','err-elem-cit-high-6-2','given-names-count-2','supp-file-xref-test-1','tr-test-2','p-bracket-test','p-punctuation-test','surname-test-5','supplementalfigure-presence','author-test-3','article-title-correction-check','supplementalfile-presence','ack-full-stop-intial-test','Inc-presence','fig-specific-test-3','duplicate-ref-test-4','table-test-2')

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
        else insert node attribute {'action'} {'fix'} as last into $m
      )
 return $copy
 
 
let $distinct := distinct-values(
                      for $x in $report//*[@action="fix"] 
                      return $x/@id
                    )

return 
  for $m in $distinct
  let $c := count($report//*[(@action="fix") and @id=$m])
  order by 1-$c
  return ($m||' - '||$c)


