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

declare function local:get-pub-date($pub-date) as xs:string{
  ($pub-date/*:year||'-'||$pub-date/*:month||'-'||$pub-date/*:day)
};

declare function local:get-authors($contrib-group) as xs:string{
  string-join(
    for $x in $contrib-group/(*:contrib[@contrib-type="author"]/*:name|*:on-behalf-of)
    return if ($x/name()='on-behalf-of') then $x
    else if ($x/*:collab) then $x/*:collab
    else if ($x/*:given-names and $x/*:surname and $x/*:suffix) then ($x/*:given-names||' '||$x/*:surname||' '||$x/*:suffix)
    else if ($x/*:given-names and $x/*:surname) then ($x/*:given-names||' '||$x/*:surname)
    else if ($x/*:surname) then $x/*:surname
    else () 
  ,', ')
};

declare function local:clean($element as node()) as xs:string{
  let $placeholder := '[Formula: see text]'
  let $new-element := copy $copy := $element
                      modify(
                        for $x in $copy//(*:inline-formula|*:disp-formula)
                        return replace node $x with $placeholder,
                        
                        for $y in $copy//*:object-id[@pub-id-type="doi"]
                        return delete node $y,
                        
                        for $z in $copy//*:p[preceding-sibling::*:p and starts-with(.,'DOI:')]
                        return delete node $z,
                        
                        for $a in $copy//*:p[preceding-sibling::*:p and not(starts-with(.,'DOI:'))]
                        return insert node ' ' before $a,
                        
                        for $b in $copy/*:title
                        return delete node $b
                      )
                      return $copy
  return $new-element
};

let $latest-articles := local:get-latest-article-list('articles')
let $pmcids := doc('/Users/fredatherden/Documents/GitHub/xquery/pmcids.xml')


let $results := 
  for $x in $latest-articles//*:item
  let $article := collection($x/text())
  where $article//*:article-meta/*:abstract[@abstract-type="executive-summary"]
  let $meta := $article//*:article-meta
  let $doi := $meta/*:article-id[@pub-id-type="doi"]
  let $pm-record := $pmcids//*:record[@requested-id = upper-case($doi)]
  let $pmid := if ($pm-record) then $pm-record/@pmid else '	'
  let $pmcid := if ($pm-record) then $pm-record/@pmcid else '	'
  let $pub-date := local:get-pub-date($meta/*:pub-date[@date-type=("publication","pub")])
  let $authors := local:get-authors($meta/*:contrib-group[1])
  let $title := data($meta//*:article-title)
  let $digest := normalize-space(local:clean($meta/*:abstract[@abstract-type="executive-summary"]))
  let $abstract := normalize-space(local:clean($meta/*:abstract[not(@abstract-type)]))
  let $result := ($doi,$pmid,$pmcid,$pub-date,$authors,$title,$abstract,$digest)
  return (string-join($result,'	')||'&#xa;')

return file:write('/Users/fredatherden/Desktop/digests.txt',$results)