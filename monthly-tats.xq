declare function local:median($vals){
  let $values := for $x in $vals order by number($x) ascending return $x
  let $count := count($values)
  let $median-number :=  if (($count mod 2)=1) then (($count div 2)+0.5)
                         else (
                            ($count div 2),
                            (($count div 2)+1)
                         )

  let $median := if (count($median-number)=1) then (
                              for $x at $p in $values
                              where $p=$median-number
                              return $x
                                              )
                 else (sum(for $x at $p in $values
                           where $p=$median-number
                           return number($x)) div 2)

  return $median
};

declare function local:get-date($s as xs:string*) {
  if (not(exists($s)) or $s='') then ()
  else xs:date($s)
};
declare variable $article-types := ('research-article','research-advance','tools-resources','review-article','short-report');

(: Taken from Kriya 2 dashboard :)
let $report := csv:parse(file:read-text('/Users/fredatherden/Documents/kriya-data/feb-report-fixed.csv'))
let $month := '2022-02'
let $pages := (1,2,3,4,5)
let $vor-url := 'https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?per-page=100&amp;page='
let $vor-text := string-join(for $page in $pages return fetch:text($vor-url||$page),'')
let $json := 
  for $x in (1,2,3,4,5)
  let $text := fetch:text('https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?per-page=100&amp;page='||string($x))
  let $fixed-text := '['||replace(string-join(tokenize($text,'\n'),','),',$','')||']'
  return json:parse($fixed-text)
let $dois := distinct-values(for $x in $json//*:_
                where $x/*:article-type=$article-types and starts-with($x/*:first-vor-published-date,$month)
                return $x/*:doi)
let $latest-articles := let $list1 := <list>{
              for $x in collection('articles')//*:article[@article-type=("research-article","review-article")]
              let $accept := $x//*:article-meta/*:history[1]/*:date[@date-type="accepted"][1]/@iso-8601-date
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" accept="{$accept}">{$b}</item>
             }</list>
 
              let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
                }</list>
             
             return $list2

let $diffs := <list>{
              for $doi in $dois
              let $id := substring-after($doi,'10.7554/eLife.')
              let $node := $latest-articles//*:item[@id=$id]
              where $node
              let $pub := distinct-values($json//*:_[*:doi=$doi][1]/*:first-vor-published-date/data())
              let $acc := $node/@accept
              let $time-diff := number(replace(string(xs:date($pub) - xs:date($acc)),'[^\d]',''))
              order by $time-diff
              return <item id="{$id}" tat="{$time-diff}" pub-date="{$pub}" accept="{$acc}"/>
          }</list>

let $list := <list>{
  for $item in $diffs//*:item
  let $id := $item/@id
  let $record := $report//*:record[*:entry[1]=$id]
  return if ($record) then (
    let $support-count := if ($record/*:entry[8]='') then 0 else $record/*:entry[8]
    let $support-days := if ($record/*:entry[9]='') then 0 else $record/*:entry[9]
    let $accept-date := local:get-date($item/@accept)
    let $export-date := local:get-date($record/*:entry[13])
    let $pre-date := local:get-date($record/*:entry[14])
    let $copy-date := local:get-date($record/*:entry[15])
    let $type-date := local:get-date($record/*:entry[16])
    let $asset-date := local:get-date($record/*:entry[17])
    let $auth-date := local:get-date($record/*:entry[19])
    let $pav-date := local:get-date($record/*:entry[21])
    let $prod-date := local:get-date($record/*:entry[22])
    let $pub-date := local:get-date($item/@pub-date)
    let $acc-to-export := number(replace(string($export-date - $accept-date),'[^\d]',''))
    let $pre-time := number(replace(string($pre-date - $export-date),'[^\d]',''))
    let $copy-time := number(replace(string($copy-date - $pre-date),'[^\d]',''))
    let $type-time := if (exists($asset-date)) then number(replace(string($asset-date - $type-date),'[^\d]',''))
                     else number(replace(string($auth-date - $type-date),'[^\d]',''))
    let $auth-time := number(replace(string($pav-date - $auth-date),'[^\d]',''))
    let $pav-time := number(replace(string($prod-date - $pav-date),'[^\d]',''))
    let $post-pav-time := number(replace(string($pub-date - $prod-date),'[^\d]',''))
    return 
    if (exists($asset-date)) then (
      let $asset-time := number(replace(string($auth-date - $asset-date),'[^\d]',''))
      return
      <item id="{$item/@id}" tat="{$item/@tat}" pub-date="{$item/@pub-date}" accept="{$item/@accept}" export="{$export-date}" acc-to-export="{$acc-to-export}" pre-time="{$pre-time}" copy-time="{$copy-time}" type-time="{$type-time}" asset-time="{$asset-time}" auth-time="{$auth-time}" pav-time="{$pav-time}" post-pav-time="{$post-pav-time}" support-count="{$support-count}" support-days="{$support-days}"/>
    )
    else <item id="{$item/@id}" tat="{$item/@tat}" pub-date="{$item/@pub-date}" accept="{$item/@accept}" export="{$export-date}" acc-to-export="{$acc-to-export}" pre-time="{$pre-time}" copy-time="{$copy-time}" type-time="{$type-time}" auth-time="{$auth-time}" pav-time="{$pav-time}" post-pav-time="{$post-pav-time}" support-count="{$support-count}" support-days="{$support-days}"/>
  )
  else $item
}</list>

let $median-acc-to-pub := 'accept to publication: '||local:median($diffs//*:item/@tat/string())
let $median-acc-to-export := 'accept to export: '||local:median($list//*:item/@acc-to-export[.!='NaN'])
let $median-pre-time := 'loading/pre-editing: '||local:median($list//*:item/@pre-time[.!='NaN'])
let $median-copy-time := 'copy-editing: '||local:median($list//*:item/@copy-time[.!='NaN'])
let $median-type-time := 'typesetter check: '||local:median($list//*:item/@type-time[.!='NaN'])
let $median-asset-time := 'waiting for assets: '||local:median($list//*:item[@asset-time]/@asset-time[.!='NaN'])
let $median-auth-time := 'author proofing: '||local:median($list//*:item/@auth-time[.!='NaN'])
let $median-pav-time := 'PAV: '||local:median($list//*:item/@pav-time[.!='NaN'])
let $median-post-pav-time := 'post-PAV: '||local:median($list//*:item/@post-pav-time[.!='NaN'])
let $median-suuport-count := 'times at support: '||local:median($list//*:item/@support-count)
let $median-suuport-days := 'days at support: '||local:median($list//*:item/@support-days)

return (
  
  string-join(
    ('Median times for '||$month||' at:',$median-acc-to-pub,$median-acc-to-export,$median-pre-time,$median-copy-time,$median-type-time,$median-asset-time,$median-auth-time,$median-pav-time,$median-post-pav-time,$median-suuport-count,$median-suuport-days)
    ,'&#xA;'
  ),
  $list
)