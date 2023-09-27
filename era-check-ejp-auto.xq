(: 
1. visit https://submit.elifesciences.org/cgi-bin/main.plex?form_type=rpt_qt_run_query&j_id=415&ms_id_key=81ftdoA0VUgcfQ3sK4l8CZPOxMw&ft_key=1AcgvYJ7m7hz790tlav2ww&rq_id=2529 and donwload excel file 

2. Save as csv

3. Run this query

4. Run era-ejp-update.xq with output of $xml-update or edit in oXygen using WebDav connection
:)

(: Return list of lastest version of articles :)
declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[*:body]
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}" base="{$b}"/>
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

let $articles := local:get-latest-article-list('articles')
let $eras := distinct-values(for $x in collection('era')//*:article return $x/@id)
let $csv := csv:parse(file:read-text('/Users/fredatherden/Desktop/eLife_query_tool_executable_research_article_answers.csv'))

let $records-of-interest := 
      for $x in $csv//*:record[contains(*:entry[1],'eLife')]
      let $id-string := substring-after($x/*:entry[1],'eLife-')
      let $id := if (contains($id-string,'R')) 
                  then if (matches(substring-before($id-string,'R'),'\d{5}')) then substring-before($id-string,'R')
                  else ('unknown - '||$x/*:entry[3])
             else if (matches($id-string,'\d{5}')) then $id-string
             else ('unknown - '||$x/*:entry[3])
      where (not($id=$eras) and contains(lower-case($x/*:entry[5]),'accept'))
      let $article := $articles//*:item[@id=$id]
      where $article
      where collection($article/@base)//*:article[//*:ext-link[matches(lower-case(@*:href),'github|gitlab|bitbucket|softwareheritage')] or //*:supplementary-material/*:caption[matches(lower-case(.),'r\s?markdown|jupyter|notebook|python')] or contains(.,'copy archived')]
      return 
      copy $copy := $x
      modify(
        insert node attribute id {$id} into $copy
      )
      return $copy

let $xml-update := <update>{
  for $x in $records-of-interest
  return <article id="{$x/@id}" status="contacted/ignored"/>
}</update>

return (
  for $x in $records-of-interest 
  return ($x/entry[1]||' '||$x/*:entry[5])
  ,
  $xml-update
)
