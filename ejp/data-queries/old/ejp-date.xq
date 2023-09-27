let $db := 'ejp-2021'

let $list := <list>{
  for $x in collection($db)//*:xml//*:version
  let $ms-no := $x/*:manuscript-number/data()
  let $no := substring(tokenize($ms-no,'-')[matches(.,'\d{5}')],1,5)
  let $corr-author-id := $x/*:authors/*:author[*:is-corr='true']/*:author-person-id
  let $corr-email := $x/ancestor::*:xml/*:people/person[*:person-id=$corr-author-id]/*:email
  let $stages := $x/*:history/*:stage
  let $latest-stage := max($stages[(not(empty(*:stage-affective-person-id)) and not(*:stage-affective-person-id='0')) or not(preceding-sibling::*:stage)]/xs:dateTime(*:start-date))
  let $emails := 
          for $email in $x/*:emails/*:email[*:email-from='editorial@elifesciences.org' and *:email-to=$corr-email]
          let $message := $email/*:email-message
          where matches($message,' [Dd]ata ') and not(matches($message,'Thank you for (submitting|sending) your|Thank you for choosing to (submit|send) your') and not(contains($message,'writing to follow up on the letter below, to see if you have any questions about the evaluation summary or public reviews')))
          return $email
  let $email-count := count($emails)
  return <item id="{$no}" ms-no="{$ms-no}" count="{$email-count}" date="{$latest-stage}"/>
}</list>


let $new-list := <list>{
  for $x in distinct-values($list//*:item/@id)
  let $items := $list//*:item[@id=$x]
  let $dateTime := max($items/xs:dateTime(@date))
  let $date := xs:date(substring-before(string($dateTime),'T'))
  order by $date
  let $count := sum($items/number(@count))
  return <item id="{$x}" count="{$count}" date="{$date}"/>
}</list>

for $x in distinct-values($new-list//*:item/@date)
order by $x
let $articles := $new-list//*:item[@date=$x]
let $email-count := sum($articles/@count)
return $x||'	'||count($articles)||'	'||$email-count
