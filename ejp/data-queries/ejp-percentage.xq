declare function local:get-percentage($number as xs:integer,
                                     $total as xs:integer) as xs:decimal{
  if ($total=0) then 0
  else ($number div $total)
};

let $root := '/Users/fredatherden/Documents/ejp-xml/output/'


let $list := <list>{
  for $file in file:list($root)[ends-with(.,'.xml')]
  let $xml := doc($root||$file)
  return $xml//*:item
}</list>

let $months := distinct-values($list//*:item/@first-month)

for $month in $months
order by $month
let $full-subs := count($list//*:item[@type="full" and @first-month=$month])
let $revised-subs := count(distinct-values($list//*:item[@type="revised" and @first-month=$month]/@id))
let $full-subs-w-emails := count($list//*:item[@type="full" and @first-month=$month and *:email])
let $revised-subs-w-emails := count(distinct-values($list//*:item[@type="revised" and @first-month=$month and *:email]/@id))
let $full-percentage := local:get-percentage($full-subs-w-emails,$full-subs)
let $revised-percentage := local:get-percentage($revised-subs-w-emails,$revised-subs)
let $results := ($month,$full-percentage,$revised-percentage,$full-subs,$revised-subs,$full-subs-w-emails,$revised-subs-w-emails)
return string-join($results,'	')