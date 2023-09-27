let $page := '1'

let $result := convert:binary-to-string(data(http:send-request(
  <http:request method='get' href="{('https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?per-page=100&amp;page='||$page)}" timeout='2'>
    <http:header name="From" value="f.atherden@elifesciences.org"/>
    <http:header name="User-Agent" value="basex"/>
  </http:request>))[2])
  
let $json := json:parse(('['||string-join(tokenize($result,'\n')[contains(.,'doi')],',')||']'))

let $dates := distinct-values(for $x in $json//*:_/*:latest-published-date return substring-before($x,'T'))

for $date in $dates
let $count := count($json//*:_[*:latest-published-date[starts-with(.,$date)]])
return ($date||' - '||$count)