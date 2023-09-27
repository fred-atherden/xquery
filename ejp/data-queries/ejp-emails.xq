let $root := '/Users/fredatherden/Documents/ejp-xml/output/'


let $list := <list>{
  for $file in file:list($root)[ends-with(.,'.xml')]
  let $xml := doc($root||$file)
  return $xml//*:item
}</list>

let $months := distinct-values($list//*:item/@first-month)

for $month in $months
order by $month
let $full-emails := sum($list//*:item[@type="full" and @first-month=$month]/@emails)
let $full-data-emails := sum($list//*:item[@type="full" and @first-month=$month]/@data-emails)
let $revised-emails := sum($list//*:item[@type="revised" and @first-month=$month]/@emails)
let $revised-data-emails := sum($list//*:item[@type="revised" and @first-month=$month]/@data-emails)
let $results := ($month,$full-emails,$full-data-emails,$revised-emails,$revised-data-emails)
return string-join($results,'	')