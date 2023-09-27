let $obsvr-url := 'https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?page='
let $pages := (1,2,3,4,5,6,7,8,9)
let $text := string-join(for $page in $pages return fetch:text($obsvr-url||$page),'')
let $json := json:parse('['||
                replace(string-join(tokenize($text,'\n'),','),',$','')||
                ']')
                
return distinct-values(for $x in $json//*:_
where (starts-with($x/*:first-published-date,'2021-07') or starts-with($x/*:first-vor-published-date,'2021-07'))
return $x/*:doi)