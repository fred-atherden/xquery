let $month := '2021-08'
let $pages := (1,2,3,4,5,6,7,8,9)

let $vor-url := 'https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?page='
let $vor-text := string-join(for $page in $pages return fetch:text($vor-url||$page),'')

let $poa-url := "https://observer.elifesciences.org/report/exeter-new-poa-articles.json?page="
let $poa-text := string-join(for $page in $pages return fetch:text($poa-url||$page),'')

let $text := ($vor-text||'&#xA;'||$poa-text)
let $json := json:parse('['||
                replace(replace(string-join(tokenize($text,'\n'),','),',$',''),',,',',')||
                ']')
       
let $dois := distinct-values(for $x in $json//*:_
                where (starts-with($x/*:first-published-date,$month) or starts-with($x/*:first-vor-published-date,$month))
                return $x/*:doi)

let $latest-articles := let $list1 := <list>{
              for $x in collection('articles')//*:article
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}">{$b}</item>
             }</list>
 
              let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
                }</list>

              return $list2

for $doi in $dois
let $id := substring-after($doi,'10.7554/eLife.')
let $node := $latest-articles//*:item[@id=$id]
let $article := collection($node/text())//*:article
let $preprint := if ($article//*:article-meta/*:pub-history)
                      then $article//*:article-meta/*:pub-history/*:event
                 else (false())
let $p-date := if ($preprint) then $preprint/*:date/@iso-8601-date
let $p-link := if ($preprint) then $preprint/*:self-uri/@*:href
let $a-dates := $json//*:_[*:doi=$doi]/first-published-date
let $a-date := if (count($a-dates)= 1) then string($a-dates)
               else if (count($a-dates)=0) then false()
               else min(for $d in $a-dates return string($d))
let $latest-updates := $json//*:_[*:doi=$doi]/latest-published-date
let $latest-update := if (count($latest-updates)= 1) then $latest-updates
                      else if (count($latest-updates)=0) then string($a-date)
                      else max(for $d in $latest-updates return string($d))
let $time-diff := if ($p-date and $a-date) then replace(string(xs:date($a-date) - xs:date($p-date)),'[^\d]','')
let $title := data($article//*:article-meta//*:article-title)
let $gscholar := 'https://scholar.google.com/scholar?hl=en&amp;as_sdt=0%2C5&amp;q='||web:encode-url($title)
order by $a-date
return ('https://doi.org/'||$doi||'	'||$a-date||'	'||$latest-update||'	'||$p-link||'	'||$p-date||'	'||$time-diff||'	'||$gscholar)