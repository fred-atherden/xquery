(: After running this, run data-queries/ejp-by-month.xq :)

declare function local:get-sub-type($version-number){
  if ($version-number='0') then 'full'
  else 'revised'
};

declare function local:get-yyyy-mm($dateTime){
  if (contains(string($dateTime),'T')) then (
    let $y-m-d := substring-before(string($dateTime),'T')
    return string-join(for $t at $p in tokenize($y-m-d,'-') where $p=(1,2) return $t,'-'))
  else if (contains(string($dateTime),' ')) then (
    let $y-m-d := substring-before(string($dateTime),' ')
    return string-join(for $t at $p in tokenize($y-m-d,'-') where $p=(1,2) return $t,'-'))
  else ''
};

let $regex-terms := ('we note that custom (software|script|code)')
let $regex := string-join($regex-terms,'|') 

let $exclusion-regex := 'please confirm your authorship in a submission to elife|article submitted to elife|decision and reviews for your submission'

let $allowed-types := ('research article', 'short report', 'research advance', 'tools and resources','research communication','replication study','registered report')

let $years := (12,13,14,15,16,17,18,19,20,21)

for $number in $years
let $year := ('20'||string($number))
let $db := 'ejp-'||$year
let $list := <list>{
for $x in collection($db)//*:xml//*:version[not(*:manuscript-type[starts-with(.,'Initial')])]
  let $ms-no := $x/*:manuscript-number/data()
  let $ms-type := lower-case($x/*:manuscript-type)
  (: Initial subs have IS in their MS no, so this excludes them :)
  where $ms-type=$allowed-types and not(contains($ms-no,'xPub') and not(contains($ms-no,'IS')))
  let $no := substring(tokenize($ms-no,'-')[matches(.,'\d{5}')],1,5)
  let $sub-type := local:get-sub-type($x/*:version-number)
  let $author-ids := $x/*:authors/*:author/*:author-person-id
  let $author-emails := $x/ancestor::*:xml/*:people/person[*:person-id=$author-ids]/*:email
  let $emails := $x/*:emails/*:email[*:email-from='editorial@elifesciences.org' and *:email-to=$author-emails and not(matches(lower-case(*:email-subject[1]),$exclusion-regex))]
  let $data-emails := 
          for $email in $emails
          let $message := $email/*:email-message
          where matches(lower-case($message),$regex)
          return $email
  let $email-count := count($emails)
  let $data-email-count := count($data-emails)
  let $stages := $x/*:history/*:stage
  let $last-stage := local:get-yyyy-mm(max($stages[(not(empty(*:stage-affective-person-id)) and not(*:stage-affective-person-id='0')) or not(preceding-sibling::*:stage)]/xs:dateTime(*:start-date)))
  let $first-stage := local:get-yyyy-mm(min($stages[(not(empty(*:stage-affective-person-id)) and not(*:stage-affective-person-id='0')) or not(preceding-sibling::*:stage)]/xs:dateTime(*:start-date)))
  
  return <item id="{$no}" ms-no="{$ms-no}" ms-type="{$ms-type}" emails="{$email-count}" data-emails="{$data-email-count}" type="{$sub-type}" first-month="{$first-stage}" last-month="{$last-stage}">{
    for $email in $data-emails
    let $dateTime := try{xs:dateTime($email/*:email-date)} catch * {$email/*:email-date/data()}
    let $yyyy-mm := try{local:get-yyyy-mm($dateTime)} catch * {''}
    return <email dateTime="{$dateTime}" yyyy-mm="{$yyyy-mm}"/>
  }</item>
 }</list>

return file:write('/Users/fredatherden/Documents/ejp-xml/output/'||$year||'.xml',$list)