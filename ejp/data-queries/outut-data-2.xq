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

let $regex-terms := ('we note that you mention a dataset,? which is available upon request',
'please update your data availability statement to indicate what data you have made available and where it can be found',
'thank you for indicating that you are unable to make this data available. exceptions to our usual data sharing policy are subject to editorial approval',
'please update your data availability statement to indicate what data you have made available',
'we note that one or more datasets are cited in your paper,? but the details have not been included in the submission form',
'data availability statement')
let $regex := string-join($regex-terms,'|') 

let $year := '2021'
let $db := 'ejp-'||$year

let $list := <list>{
for $x in collection($db)//*:xml//*:version[not(*:manuscript-type[starts-with(.,'Initial')])]
  let $ms-no := $x/*:manuscript-number/data()
  (: Initial subs have IS in their MS no, so this excludes them :)
  where not(contains($ms-no,'xPub') and not(contains($ms-no,'IS')))
  let $no := substring(tokenize($ms-no,'-')[matches(.,'\d{5}')],1,5)
  let $type := local:get-sub-type($x/*:version-number)
  let $author-ids := $x/*:authors/*:author/*:author-person-id
  let $author-emails := $x/ancestor::*:xml/*:people/person[*:person-id=$author-ids]/*:email
  let $emails := 
          for $email in $x/*:emails/*:email[*:email-from='editorial@elifesciences.org' and *:email-to=$author-emails]
          let $message := $email/*:email-message
          where matches(lower-case($message),$regex)
          return $email
  let $email-count := count($emails)
  let $stages := $x/*:history/*:stage
  let $last-stage := local:get-yyyy-mm(max($stages[(not(empty(*:stage-affective-person-id)) and not(*:stage-affective-person-id='0')) or not(preceding-sibling::*:stage)]/xs:dateTime(*:start-date)))
  let $first-stage := local:get-yyyy-mm(min($stages[(not(empty(*:stage-affective-person-id)) and not(*:stage-affective-person-id='0')) or not(preceding-sibling::*:stage)]/xs:dateTime(*:start-date)))
  
  return <item id="{$no}" ms-no="{$ms-no}" count="{$email-count}" type="{$type}" first-month="{$first-stage}" last-month="{$last-stage}">{
    for $email in $emails
    let $dateTime := try{xs:dateTime($email/*:email-date)} catch * {$email/*:email-date/data()}
    let $yyyy-mm := try{local:get-yyyy-mm($dateTime)} catch * {''}
    return <email dateTime="{$dateTime}" yyyy-mm="{$yyyy-mm}"/>
  }</item>
 }</list>

return file:write('/Users/fredatherden/Documents/ejp-xml/output/'||$year||'.xml',$list)