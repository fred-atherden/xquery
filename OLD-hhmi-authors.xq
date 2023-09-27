declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[@article-type="research-article"]
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              where $type != 'feature article'
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

declare function local:get-name($name) as xs:string* {
  if ($name/name() = 'name') then (
    if ($name/given-names[1] and $name/surname[1] and $name/suffix[1]) then concat($name/given-names[1],' ',$name/surname[1],' ',$name/suffix[1])
    else if (not($name/given-names[1]) and $name/surname[1] and $name/suffix[1]) then concat($name/surname[1],' ',$name/suffix[1])
    else if ($name/given-names[1] and $name/surname[1] and not($name/suffix[1])) then concat($name/given-names[1],' ',$name/surname[1])
    else $name/surname[1]
  )
 else if ($name/*) then ($name/*[1]/text()[1])
 else (
   $name/data()
 )
};

declare function local:xref2aff($xref){
  let $rid := $xref/@rid
  return $xref/ancestor::*:article//*:aff[@id=$rid]
};

declare function local:hhmi-authors($article){
   string-join(
    for $y in $article//*:article-meta//*:contrib[@contrib-type="author"]
    let $affs :=  ($y/*:aff, 
                  for $z in $y/*:xref return local:xref2aff($z))
    return if (some $a in $affs satisfies (matches(lower-case($a),'hhmi|howard hughe?s|janelia'))) then local:get-name($y/*)
    ,'; ')
};

declare function local:hhmi-corr-authors($article){
   string-join(
    for $y in $article//*:article-meta//*:contrib[@contrib-type="author" and @corresp="yes"]
    let $affs :=  ($y/*:aff, 
                  for $z in $y/*:xref return local:xref2aff($z))
    return if (some $a in $affs satisfies (matches(lower-case($a),'hhmi|howard hughe?s|janelia'))) then local:get-name($y/*)
    ,'; ')
};

declare variable $article-types := ('research-article','research-advance','tools-resources','short-report');


let $latest-articles := local:get-latest-article-list('articles')

let $csv := <csv>
<record>
<entry>Publication year</entry>
<entry>DOI</entry>
<entry>title</entry>
<entry>HHMI affiliated authors</entry>
</record>
{
for $x in $latest-articles//*:item
  let $article := collection($x/text())//*:article[@article-type=$article-types]
  let $title := $article//*:article-meta/*:title-group/*:article-title/data() 
  let $doi := ('https://doi.org/'||$article//*:article-meta/*:article-id[@pub-id-type="doi"][1])
  let $pub-year := $article//*:article-meta//*:pub-date[@date-type=('pub','publication')]/*:year
  let $hhmi-authors := local:hhmi-authors($article)
  let $pub-model := if ($article//*:article-meta//*:custom-meta[*:meta-value='prc']) then 'new' 
                    else 'old' 
  order by number($pub-year)
  where ($hhmi-authors!='' or 
        (some $f in $article//*:article-meta/*:funding-group/award-group//institution satisfies matches(lower-case($f),'hhmi|howard hughe?s'))
      )
  return <record>
           <entry>VOR</entry>
           <entry>{data($pub-year)}</entry>
           <entry>{$doi}</entry>
           <entry>{$title}</entry>
           <entry>{$hhmi-authors}</entry>
           <entry>{$pub-model}</entry>
         </record>
}</csv>

return file:write('/Users/fredatherden/Desktop/hhmi-articles.csv',$csv, map{'method':'csv','encoding':'UTF-8'})