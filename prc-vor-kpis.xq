declare variable $month := '2023-07';
declare variable $article-types := ('research-article','research-advance','tools-resources','review-article','short-report');

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

declare function local:get-latest-prc-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[//*:article-meta//*:custom-meta/*:meta-value='prc']
              let $pub-date := $x//*:article-meta/*:pub-date[@publication-format="electronic"]
              let $pub-date := $pub-date/*:year||'-'||$pub-date/*:month||'-'||$pub-date/*:day
              where starts-with($pub-date,$month)
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" pub-date="{$pub-date}">{$b}</item>
              }</list>
  let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
                  }</list>
  return $list2
};

let $latest-articles := local:get-latest-prc-article-list('articles')


(: to get the excel file run Query: RP9 - Article tracking in eJP and then save as csv :)
let $sub-csv := csv:parse(file:read-text('/Users/fredatherden/Downloads/elife-rp_query_tool_rp09__article_tracking.csv'))
(: go to https://docs.google.com/spreadsheets/d/16Lggo9KtTftw8MSsEjiRczW_GhcLaiJ2p9d_0NEL6_A/edit#gid=0 and save as csv :)
let $pass-csv := csv:parse(file:read-text('/Users/fredatherden/Downloads/pass.csv'))

let $subs-to-vor := local:median(
      for $x in $latest-articles//*:item
      let $date := xs:date($x/@pub-date)
      let $init-sub := $sub-csv//*:record[entry[1]=$x/@id and entry[last()]='After Peer Review'][1]/entry[4]
      (: will ignore legacy site ones :)
      where $init-sub
      let $sub-date := xs:date(string-join(for $y at $p in tokenize($init-sub,'/') order by $p descending return $y,'-'))
      return ($date - $sub-date) div xs:dayTimeDuration("P1D")
    )
let $pass-to-vor := local:median(
      for $x in $latest-articles//*:item
      let $date := xs:date($x/@pub-date)
      let $pass-sub := $pass-csv//*:record[entry[1]=$x/@id and lower-case(entry[2])='prc'][1]/entry[3]
      (: will ignore legacy site ones :)
      where $pass-sub
      let $sub-date := xs:date(string-join(for $y at $p in tokenize($pass-sub,'/') order by $p descending return $y,'-'))
      return ($date - $sub-date) div xs:dayTimeDuration("P1D")
    )

return (
  $subs-to-vor,
  $pass-to-vor
)