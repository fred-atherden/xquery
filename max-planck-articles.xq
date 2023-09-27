declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article
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
};

declare function local:xref2aff($xref){
  let $rid := $xref/@rid
  return $xref/ancestor::*:article//*:aff[@id=$rid]
};

declare function local:maxp-author-count($article){
  count(
    for $y in $article//*:article-meta//*:contrib[@contrib-type="author"]
    let $affs :=  ($y/*:aff, 
                  for $z in $y/*:xref return local:xref2aff($z))
    return if (some $a in $affs satisfies (matches(lower-case($a),'max\splan|max\p{P}plan'))) then $y
    )
};


let $latest-articles := local:get-latest-article-list('articles')

let $csv := <csv>{
for $x in $latest-articles//*:item
let $article := collection($x/text())//*:article
let $doi := ('https://doi.org/'||$article//*:article-meta/*:article-id[@pub-id-type="doi"][1])
let $pub-year := $article//*:article-meta//*:pub-date[@date-type=('pub','publication')]/*:year
order by number($pub-year)
let $max-p-count := local:maxp-author-count($article)
where $max-p-count != 0
return <record>
         <entry>{data($pub-year)}</entry>
         <entry>{$doi}</entry>
         <entry>{$max-p-count}</entry>
       </record>
}</csv>

return (
  file:write('/Users/fredatherden/Desktop/max-planck-affiliations.csv',$csv, map{'method':'csv'}),
  for $x in distinct-values($csv//*:record/entry[1])
    return 
    ($x||' No. of articles: '||count($csv//*:record[entry[1]=$x])||' No. of authors: '||sum($csv//*:record[entry[1]=$x]/entry[3]))
)