let $regex-terms := ('we note that you mention a dataset,? which is available upon request',
'please update your data availability statement to indicate what data you have made available and where it can be found',
'thank you for indicating that you are unable to make this data available. exceptions to our usual data sharing policy are subject to editorial approval',
'please update your data availability statement to indicate what data you have made available',
'we note that one or more datasets are cited in your paper,? but the details have not been included in the submission form',
"'?datasets'? section of the submission form",
'data availability statement')
let $regex := string-join($regex-terms,'|') 

let $exclusion-regex := 'please confirm your authorship in a submission to elife|article submitted to elife|decision and reviews for your submission|elife decision:|please upload your full submission for review at eLife'
let $db := 'ejp-2015'

for $x in collection($db)//*:xml//*:version[not(*:manuscript-type[starts-with(.,'Initial')])]
let $corr-author-id := $x/*:authors/*:author[*:is-corr='true']/*:author-person-id
let $corr-email := $x/ancestor::*:xml/*:people/person[*:person-id=$corr-author-id]/*:email
let $emails := $x/*:emails/*:email[*:email-from='editorial@elifesciences.org' and *:email-to=$corr-email and not(matches(lower-case(*:email-subject[1]),$exclusion-regex))]
let $stages := $x/*:history/*:stage

for $email in $emails
let $message := $email/*:email-message
where matches($message,'[Dd]ata') and not(matches(lower-case($message),$regex))
let $email-date := xs:dateTime($email/*:email-date)
let $stage := $stages[xs:dateTime(*:start-date) = max($stages[xs:dateTime(*:start-date) lt $email-date]/xs:dateTime(*:start-date))][last()]/*:stage-name
return ($stage,$email)
