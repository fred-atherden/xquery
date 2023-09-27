declare variable $sch := doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/schematron.sch');

let $messages := 
for $x in $sch//*:rule[@id="unicode-tests"]//(*:report|*:assert)
let $message := normalize-space(string-join(for $y in $x/(*|text()) return if ($y/local-name()='value-of') then ("XXXXXX") else if ($y/local-name()='name') then ("XXXXXX") else $y))
let $action := ('This message suggests that something has gone wrong with the unicode parsing of the JATS posted to Kriya, and will fire if the character(s) '||substring-before(substring-after($message,'element contains '),' ')||' are present in a Decision letter or Author response. To resolve this replace those characters with the one suggested in the message, in this case, '||substring-before(substring-after($message,'be the character '),' ')||" The first XXXXXX will be the name of the element (e.g. 'p'), and the second XXXXXX is the content within that element. If there are a large number of errors relating to incorrect unicode characters, then the eLife Production team should send the article back to Exeter to fix them all.")
return (
  ("**"||$x/@id||"**"||'&#xa;&#xa;'||"**"||upper-case(substring($x/@role,1,1))||substring($x/@role,2)||'**: _'||$message||'_'||'&#xa;&#xa;'||"**Action**: "||$action||'&#xa;&#xa;&#xa;')
)

return file:write('/Users/fredatherden/Desktop/gitbook-messages.txt',$messages)