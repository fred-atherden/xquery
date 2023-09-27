(: first run this command in the terminal:
aws s3 cp s3://elife-striking-images/ /Users/fredatherden/Desktop/ --dryrun --exclude "*.txt" --exclude "*.doc" --recursive > /Users/fredatherden/Desktop/striking-images.txt
:)

declare function local:day-of-week
  ( $date as xs:anyAtomicType? )  as xs:string? {
  let $num := if (empty($date)) then () 
              else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7
  return ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')[$num +1]
 };

let $current-date := current-date()
let $current-day-of-week := local:day-of-week($current-date)

let $last-wednesday := for $x in 1 to 7
                       let $date := $current-date - xs:dayTimeDuration('P'||$x||'D')
                       where local:day-of-week($date) = "Wednesday"
                       return $date
let $last-wed-string := substring-before(string($last-wednesday),'Z')
let $current-date-string := substring-before(string($current-date),'Z')

let $obsvr-url := 'https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?page='
let $pages := (1,2)
let $text := string-join(for $page in $pages return fetch:text($obsvr-url||$page),'')
let $json := json:parse('['||
                replace(string-join(tokenize($text,'\n'),','),',$','')||
                ']')

let $published-dois := $json//*:_[(*:first-vor-published-date ge $last-wed-string) and (*:first-vor-published-date le $current-date-string)]/*:doi/data()

let $striking-image-list := <list>{
  for $x in tokenize(file:read-text('/Users/fredatherden/Desktop/striking-images.txt'),'\n')
  let $path := "s3://"||substring-before(substring-after($x,'s3://'),' to ')
  let $id := replace(tokenize($path,'/')[matches(replace(.,'[^\d]',''),'^\d{5}$')][1],'[^\d]','')
  return <item id="{$id}" path="{$path}"/>
}</list>

for $x in $published-dois
let $id := substring-after($x,'10.7554/eLife.')
let $aws-s-i := string-join($striking-image-list//*:item[@id=$id]/@path/string(),' | ')
return $x||' '||$aws-s-i