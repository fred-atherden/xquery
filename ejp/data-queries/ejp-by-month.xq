let $root := '/Users/fredatherden/Documents/ejp-xml/output/'


let $list := <list>{
  for $file in file:list($root)[ends-with(.,'.xml')]
  let $xml := doc($root||$file)
  return $xml//*:item
}</list>

let $months := distinct-values($list//*:item/@first-month)

for $month in $months
order by $month
let $full-emails := count($list//*:email[@yyyy-mm=$month and parent::*:item/@type="full"])
let $revised-emails := count($list//*:email[@yyyy-mm=$month and parent::*:item/@type="revised"])
let $total-emails := $full-emails + $revised-emails
let $full-subs := count($list//*:item[@type="full" and @first-month=$month])
let $revised-subs := count(distinct-values($list//*:item[@type="revised" and @first-month=$month]/@id))
let $results := ($month,$full-emails,$revised-emails,$total-emails,$full-subs,$revised-subs)
return string-join($results,'	')