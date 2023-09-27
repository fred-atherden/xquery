let $year := '2022'
let $obsvr-url := 'https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?per=page=100&amp;page='
let $pages := (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
let $text := string-join(for $page in $pages return fetch:text($obsvr-url||$page),'')
let $json := json:parse('['||
                replace(string-join(tokenize($text,'\n'),','),',$','')||
                ']')

let $list := <list>{
  for $x in distinct-values($json//*:_/*:doi)
             let $i := $json//*:_[*:doi=$x][1]
             let $date := $i/*:first-vor-published-date
             where starts-with($date,$year)
             return <item doi="{$i/*:doi}" date="{string-join(tokenize($i/*:first-vor-published-date,'-')[not(position()=last())],'-')}"></item>
}</list>

return (
  'Total: '||count($list//*:item),
  for $x in distinct-values($list//*:item/@date)
  order by $x descending
  let $count := count($list//*:item[@date=$x])
  return $x||': '||$count
)