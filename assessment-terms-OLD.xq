declare variable $ms-json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'));

declare function local:getAssessmentTerms($msid,$version) {
  (: Wait one second before making the next request so as not to overload server :)
  prof:sleep(1000),
  let $endpoint := 'https://staging--epp.elifesciences.org/api/reviewed-preprints/'||$msid||'/v'||$version||'/reviews'
  let $text := try {lazy:cache(fetch:text($endpoint))}
               catch * {''}
  where $text
  let $assessment := json:parse($text)//*:evaluationSummary/*:text
  let $terms := analyze-string(lower-case($assessment),'landmark|fundamental|important|valuable|useful|exceptional|compelling|convincing|solid|incomplete|inadequate|incompletely|inadequately|convincingly')//*:match/data()
  return $terms
};

let $terms := for $ms in $ms-json//*:manuscripts/*[*]
              let $terms := local:getAssessmentTerms($ms/*:msid,$ms/*:version)
              return $terms

for $term in distinct-values($terms)
let $count := count($terms[.=$term])
return $term||' '||$count