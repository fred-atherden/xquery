let $db := 'ejp-2021'

let $csv := <csv>{
  for $x in collection($db)//*:xml//*:version
  let $ms-no := $x/*:manuscript-number/data()
  let $corr-author-id := $x/*:authors/*:author[*:is-corr='true']/*:author-person-id
  let $corr-email := $x/ancestor::*:xml/*:people/person[*:person-id=$corr-author-id]/*:email
  let $emails := $x/*:emails/*:email[*:email-from='editorial@elifesciences.org' and *:email-to=$corr-email]
  let $stages := $x/*:history/*:stage

  let $entries := 
    for $email in $emails
    let $message := $email/*:email-message
    where matches($message,' [Dd]ata ') and not(matches($message,'Thank you for (submitting|sending) your|Thank you for choosing to (submit|send) your') and not(contains($message,'writing to follow up on the letter below, to see if you have any questions about the evaluation summary or public reviews')))
    let $email-date := xs:dateTime($email/*:email-date)
    let $stage := $stages[xs:dateTime(*:start-date) = max($stages[xs:dateTime(*:start-date) lt $email-date]/xs:dateTime(*:start-date))][last()]/*:stage-name
    return (<entry>{$stage/data()}</entry>,<entry>{normalize-space($message/data())}</entry>)
  
  return <record><entry>{$ms-no}</entry>{$entries}</record>
}</csv>

return file:write('/Users/fredatherden/Desktop/ejp-test.csv',$csv, map{'method':'csv'})