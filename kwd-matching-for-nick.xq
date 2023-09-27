(: Function to generate list of all articles with their subjects and keywords :)
declare function local:collate-kwds(){
  let $list1 := <list>{
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

let $kwd-list := 
<list>{
  for $x in $list2//*:item
  let $article := collection($x/text())/*:article
  let $subj := $article//*:article-meta/article-categories//*:subj-group[@subj-group-type="heading"]/*:subject
  let $kwds := $article//*:article-meta/*:kwd-group[not(@kwd-group-type="research-organism")]/*:kwd
  return <item id="{$x/@id}">{$subj,$kwds}</item>
}</list>

return file:write('/Users/fredatherden/Desktop/kwd-list.xml',$kwd-list)
};

(:  :)
declare function local:subj-score($subjs-1 as xs:anyAtomicType*,
                                  $subjs-2 as xs:anyAtomicType*) 
                                  as xs:decimal {
  let $count-1 := count($subjs-1)
  let $count-2 := count($subjs-2)
  
  let $score := sum(
  if (($count-1 = 1) and ($count-2 = 1))
    then (if ($subjs-1 = $subjs-2) then 2
          else 0)
  else if (($count-1 = 2) and $count-1 = 2)
    then (
      for $subj in $subjs-1
      return if ($subj = $subjs-2) then 1
      else 0
    )
  else if ($count-1 = 2)
    then (
      for $subj in $subjs-1
      return if ($subj = $subjs-2) then 1
      else 0
    )
  else for $subj in $subjs-2
      return if ($subj = $subjs-1) then 1
      else 0
  )
  
  return $score
};


(: Function already run and output as file, just being read in here to save memory :)
let $kwd-list := doc('/Users/fredatherden/Desktop/kwd-list.xml')

let $articles := ('57646', '62048', '60860', '61907', '64501', '59683')

for $a in $articles
let $item := $kwd-list//*:item[@id = $a]
let $subjs := $item/*:subject/lower-case(.)
let $kwds := $item/*:kwd/lower-case(.)

let $subj-matches := $kwd-list//*:item[(@id != $a) and *:subject[lower-case(.) = $subjs]]

  for $match in $subj-matches
  let $subj-score := local:subj-score($subjs,$match/*:subject/lower-case(.))
  let $kwd-count := count(
                      for $kwd in $match//*:kwd 
                      where some $a-kwd in $kwds satisfies (contains($a-kwd,lower-case($kwd)))
                      return $kwd
                      ) +
                    count(
                      for $kwd in $kwds
                      where some $m-kwd in $match//*:kwd/lower-case(.) satisfies contains($m-kwd,$kwd)
                      return $kwd 
                      )
  order by (1-$kwd-count + $subj-score)
  return ($a||': match https://elifesciences.org/articles/'||$match/@id||' subj: '||$subj-score||' keywords: '||$kwd-count)
    