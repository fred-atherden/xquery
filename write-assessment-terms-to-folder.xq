declare variable $ms-json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'));
declare variable $ass-term-folder := '/Users/fredatherden/Desktop/assessment-terms/';

declare function local:getAssessmentTerms($msid,$version,$pub-date) {
  (: Wait one second before making the next request so as not to overload server :)
  prof:sleep(1000),
  let $endpoint := 'https://staging--epp.elifesciences.org/api/reviewed-preprints/'||$msid||'/v'||$version||'/reviews'
  let $text := try {lazy:cache(fetch:text($endpoint))}
               catch * {''}
  where $text
  let $assessment := json:parse($text)//*:evaluationSummary/*:text
  return 
  <terms id="{$msid}" version="{$version}" pub-date="{$pub-date}">{(
   for $x in analyze-string(lower-case($assessment),'landmark|fundamental|important|valuable|useful|exceptional|compelling|convincing|solid|incomplete|inadequate|incompletely|inadequately|convincingly')//*:match/data()
    let $type := if (matches($x,'landmark|fundamental|important|valuable|useful')) then 'significance'
                 else ('strength')
    return <term type="{$type}">{$x}</term>,
    <assessment>{replace(tokenize($assessment,'\n')[2],'</?p>','')}</assessment>
  )
  }</terms>
};

for $ms in $ms-json//*:manuscripts/*[*]
let $msid := $ms/*:msid
let $msv := $ms/*:version
let $pub-date := if ($msv='1') then $ms/*:status/*:timeline/*[(lower-case(name[1])='reviewed preprint posted') or contains(name[1],('version '||$msv))]/date
                 else $ms/*:status/*:timeline/*[contains(name[1],('version '||$msv))]/date
let $filepath := $ass-term-folder||$msid||'v'||$msv||'.xml'
return if (file:exists($filepath)) then ()
else (
  let $terms := local:getAssessmentTerms($msid,$msv,$pub-date)
  return file:write($filepath,$terms)
)