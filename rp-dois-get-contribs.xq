let $articles := <list>
<article id="86791" version="1"/>
<article id="87698" version="1"/>
<article id="87196" version="1"/>
<article id="86638" version="1"/>
<article id="87912" version="1"/>
<article id="88205" version="1"/>
<article id="88319" version="1"/>
<article id="87037" version="2"/>
<article id="88058" version="2"/>
</list>
let $xml-loc := 'https://raw.githubusercontent.com/elifesciences/enhanced-preprints-data/master/data/'
let $xml-dir := '/Users/fredatherden/Documents/GitHub/elife-crossref-xml-generation/tmp/biorxiv/'

return (
  for $a in $articles//*:article
  return 'article_list.append(ARTICLE_'||$a/@id||')'
  ,
  for $a in $articles//*:article
  let $v := $a/@version/string()
  let $docmap := json:parse(fetch:text('https://data-hub-api.elifesciences.org/enhanced-preprints/docmaps/v1/by-publisher/elife/get-by-manuscript-id?manuscript_id='||$a/@id))
  let $preprint := $docmap//*:steps/*[1]//*:outputs/*[type="preprint"]/*:doi/string()
  let $editor := $docmap/descendant::*:participants[*[*:role='editor']][1]/*[*:role='editor']/*:actor/*:name
  let $editor-surname := <surname>{tokenize($editor,'\s')[last()]}</surname>
  let $editor-given := <given__name>{tokenize($editor,'\s')[position()!=last()]}</given__name>
  let $sub := replace(substring-after($preprint,'/'),'/','-')
  let $xml := fetch:xml(($xml-loc||$a/@id||'/v'||$a/@version||'/'||$a/@id||'-v'||$a/@version||'.xml'))
  let $date := substring-before(string(current-dateTime()),'T')
  let $json := <json type="object">
  <vor__exists>False</vor__exists>
  <id>{$a/@id/string()}</id>
  <title>{$xml//*:article-meta/title-group/article-title/data()}</title>
  <date>{$date}</date>
  <doi>{'10.7554/eLife.'||$a/@id||'.'||$v}</doi>
  <uri>{'https://elifesciences.org/reviewed-preprints/'||$a/@id||'v'||$v}</uri>
  <concept__doi>{'10.7554/eLife.'||$a/@id}</concept__doi>
  <concept__uri>{'https://elifesciences.org/reviewed-preprints/'||$a/@id}</concept__uri>
  <preprint__doi>{$preprint}</preprint__doi>
  <xml__file>{$sub||'.xml'}</xml__file>
  <peer__reviews type="array">
    <_ type="object">
      <article__type>editor-report</article__type>
      <doi>{'10.7554/eLife.'||$a/@id||'.'||$v||'.sa0'}</doi>
      <title>eLife assessment</title>
      <uri>{'https://elifesciences.org/reviewed-preprints/'||$a/@id||'v'||$v}</uri>
      <date>{$date}</date>
      <contributors type="array">
         <_ type="object">
          <contrib__type>author</contrib__type>{(
            $editor-surname,
            $editor-given
          )}</_>
      </contributors>
    </_>
    <_ type="object">
      <article__type>referee-report</article__type>
      <doi>{'10.7554/eLife.'||$a/@id||'.'||$v||'.sa1'}</doi>
      <title>Reviewer #1 (Public Review)</title>
      <uri>{'https://elifesciences.org/reviewed-preprints/'||$a/@id||'v'||$v}</uri>
      <date>{$date}</date>
      <contributors type="array">
         <_ type="object">
          <contrib__type>author</contrib__type>
          <anonymous>True</anonymous>
          </_>
      </contributors>
    </_>
    <_ type="object">
      <article__type>referee-report</article__type>
      <doi>{'10.7554/eLife.'||$a/@id||'.'||$v||'.sa2'}</doi>
      <title>Reviewer #2 (Public Review)</title>
      <uri>{'https://elifesciences.org/reviewed-preprints/'||$a/@id||'v'||$v}</uri>
      <date>{$date}</date>
      <contributors type="array">
         <_ type="object">
          <contrib__type>author</contrib__type>
          <anonymous>True</anonymous>
          </_>
      </contributors>
    </_>
    <_ type="object">
      <article__type>referee-report</article__type>
      <doi>{'10.7554/eLife.'||$a/@id||'.'||$v||'.sa3'}</doi>
      <title>Reviewer #3 (Public Review)</title>
      <uri>{'https://elifesciences.org/reviewed-preprints/'||$a/@id||'v'||$v}</uri>
      <date>{$date}</date>
      <contributors type="array">
         <_ type="object">
          <contrib__type>author</contrib__type>
          <anonymous>True</anonymous>
          </_>
      </contributors>
    </_>
    <_ type="object">
      <article__type>author-comment</article__type>
      <doi>{'10.7554/eLife.'||$a/@id||'.'||$v||'.sa4'}</doi>
      <title>Author response</title>
      <uri>{'https://elifesciences.org/reviewed-preprints/'||$a/@id||'v'||$v}</uri>
      <date>{$date}</date>
      <contributors type="array"/>
      </_>
  </peer__reviews>
</json>


return (
  ('ARTICLE_'||$a/@id||' = '||replace(replace(replace(json:serialize($json),':"False"',': False'),':"True"',': True,'),'\\/','/')),
  file:write(($xml-dir||$sub||'.xml'),$xml)
)
)
