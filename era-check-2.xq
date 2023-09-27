(: Return list of lastest version of articles :)
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


let $latest-articles := local:get-latest-article-list('articles')
let $obsvr-url := 'https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?page='
let $pages := (1,2,3)
let $text := string-join(for $page in $pages return fetch:text($obsvr-url||$page),'')
let $json := json:parse('['||
                replace(string-join(tokenize($text,'\n'),','),',$','')||
                ']')

let $eras := distinct-values(collection('era')//*:article/@id)
let $ejp-answs := for $x in csv:parse(file:read-text('/Users/fredatherden/Desktop/eLife_query_tool_executable_research_article_answers.csv'))//*:record[contains(*:entry[1],'eLife')]
                  let $id-string := substring-after($x/*:entry[1],'eLife-')
                  let $id := if (contains($id-string,'R')) 
                                then if (matches(substring-before($id-string,'R'),'\d{5}')) then substring-before($id-string,'R')
                                else ('unknown - '||$x/*:entry[3])
                             else if (matches($id-string,'\d{5}')) then $id-string
                             else ('unknown - '||$x/*:entry[3])
                  return 
                  copy $copy := $x
                  modify(insert node attribute id {$id} into $copy)
                  return $copy

for $obj in $json//*:_
let $doi := $obj/*:doi
let $id := substring-after($doi,'10.7554/eLife.')
let $pub-date := $obj/*:first-vor-published-date
let $base-uri := $latest-articles//*:item[@id=$id]/text()
let $ejp-answ := if ($ejp-answs/@id = $id) then "yes" else "no"
where not(empty($base-uri)) and not($id=$eras)
order by $pub-date descending
let $article := collection($base-uri)//*:article
return 
  if ($article//*:ext-link[contains(@*:href,'softwareheritage')]) then ('('||$pub-date||') '||data($doi)||' SWH eJP: '||$ejp-answ)
  else if ($article//*:supplementary-material/*:caption[matches(lower-case(.),'r\s?markdown|jupyter|notebook|python')]) then 
   ('('||$pub-date||') '||$doi||' file. eJP: '||$ejp-answ)
  else if ($article//*:sec[@sec-type="data-availability"]//*:element-citation[@specific-use="isSupplementedBy"]/*:source[matches(lower-case(.),'dryad|open science framework|^osf$|figshare|zenodo')]) then ('('||$pub-date||') '||$doi||' '||string-join(distinct-values($article//*:sec[@sec-type="data-availability"]//*:element-citation[@specific-use="isSupplementedBy"]/*:source[matches(lower-case(.),'dryad|open science framework|^osf$|figshare|zenodo')]),'; ')||' '||$ejp-answ)
  else ()