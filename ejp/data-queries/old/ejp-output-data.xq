declare function local:get-year-month($dateTime){
  if (contains(string($dateTime),'T')) then (
    let $y-m-d := substring-before(string($dateTime),'T')
    return string-join(for $t at $p in tokenize($y-m-d,'-') where $p=(1,2) return $t,'-'))
  else if (contains(string($dateTime),' ')) then (
    let $y-m-d := substring-before(string($dateTime),' ')
    return string-join(for $t at $p in tokenize($y-m-d,'-') where $p=(1,2) return $t,'-'))
  else ''
};

let $year := '2018'
let $db := 'ejp-'||$year


let $list := <list>{
  for $x in collection($db)//*:xml//*:version
  let $ms-no := $x/*:manuscript-number/data()
  where not(contains($ms-no,'xPub'))
  let $no := substring(tokenize($ms-no,'-')[matches(.,'\d{5}')],1,5)
  let $corr-author-id := $x/*:authors/*:author[*:is-corr='true']/*:author-person-id
  let $corr-email := $x/ancestor::*:xml/*:people/person[*:person-id=$corr-author-id]/*:email
  let $stages := $x/*:history/*:stage
  let $last-stage := max($stages[(not(empty(*:stage-affective-person-id)) and not(*:stage-affective-person-id='0')) or not(preceding-sibling::*:stage)]/xs:dateTime(*:start-date))
  let $first-stage := min($stages[(not(empty(*:stage-affective-person-id)) and not(*:stage-affective-person-id='0')) or not(preceding-sibling::*:stage)]/xs:dateTime(*:start-date))
  let $emails := 
          for $email in $x/*:emails/*:email[*:email-from='editorial@elifesciences.org' and *:email-to=$corr-email]
          let $message := $email/*:email-message
          where matches($message,' [Dd]ata ') and not(matches($message,'Thank you for (submitting|sending) your|Thank you for choosing to (submit|send) your') and not(contains($message,'writing to follow up on the letter below, to see if you have any questions about the evaluation summary or public reviews')))
          return $email
  let $email-count := count($emails)
  return <item id="{$no}" ms-no="{$ms-no}" count="{$email-count}" first-date="{$first-stage}" last-date="{$last-stage}">{
    for $email in $emails
    let $date := try{xs:dateTime($email/*:email-date)} catch * {$email/*:email-date/data()}
    return <email dateTime="{$date}"/>
  }</item>
}</list>


let $new-list := <list>{
  for $x in distinct-values($list//*:item/@id)
  let $items := $list//*:item[@id=$x]
  let $first-date := min($items/xs:dateTime(@first-date))
  let $last-date := max($items/xs:dateTime(@last-date))
  order by $first-date
  let $month := local:get-year-month($first-date)
  let $count := sum($items/number(@count))
  return <item id="{$x}" count="{$count}" first-date="{$first-date}" last-date="{$last-date}" month="{$month}">{
    for $email in $items//*:email
    return <email date="{local:get-year-month($email/@dateTime)}" dateTime="{$email/@dateTime}"/>
  }</item>
}</list>

return file:write('/Users/fredatherden/Documents/ejp-xml/output/'||$year||'.xml',$new-list)