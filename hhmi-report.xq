(: PULL LATEST POA/VOR XML FROM GIT REPO AND UPDATE DB articles :)
(: UPDATE $month :)
declare variable $month := '2023-10';

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

declare function local:hhmi-authors($article,$is-corr as xs:boolean){
  if ($is-corr) then (
    string-join(
    for $y in $article//*:article-meta//*:contrib[@contrib-type="author" and @corresp="yes"]
    let $affs :=  ($y/*:aff, 
                  for $z in $y/*:xref return local:xref2aff($z))
    return if (some $a in $affs satisfies (matches(lower-case($a),'hhmi|howard hughe?s|janelia'))) then local:get-name($y/*)
    ,'; ')
  )
  else (
   string-join(
    for $y in $article//*:article-meta//*:contrib[@contrib-type="author"]
    let $affs :=  ($y/*:aff, 
                  for $z in $y/*:xref return local:xref2aff($z))
    return if (some $a in $affs satisfies (matches(lower-case($a),'hhmi|howard hughe?s|janelia'))) then local:get-name($y/*)
    ,'; ')
  )
};

declare variable $article-types := ('research-article','research-advance','tools-resources','short-report');

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
              let $doi := '10.7554/eLife.'||$id
              where $dois[.=$doi]
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

let $rp-json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'))


let $hhmi-art := <csv>
<record>
<entry>Publication type</entry>
<entry>Publication year</entry>
<entry>DOI</entry>
<entry>title</entry>
<entry>HHMI affiliated authors</entry>
<entry>Publication model</entry>
</record>
{
(
  for $x in $latest-articles//*:item
  let $article := collection($x/text())//*:article
  let $title := $article//*:article-meta/*:title-group/*:article-title/data() 
  let $doi := ('https://doi.org/'||$article//*:article-meta/*:article-id[@pub-id-type="doi"][1])
  let $pub-year := $article//*:article-meta//*:pub-date[@date-type=('pub','publication')]/*:year
  let $hhmi-authors := local:hhmi-authors($article,false())
  let $pub-model := if ($article//*:article-meta//*:custom-meta[*:meta-value='prc']) then 'new' 
                    else 'old' 
  order by number($pub-year)
  where ($hhmi-authors!='')
  return <record>
           <entry>VOR</entry>
           <entry>{data($pub-year)}</entry>
           <entry>{$doi}</entry>
           <entry>{$title}</entry>
           <entry>{$hhmi-authors}</entry>
           <entry>{$pub-model}</entry>
         </record>
  ,
  for $item in $rp-json//*:manuscripts/*[not(*:msid)]/text()
  let $rp := $rp-json//*:manuscripts/*[*:msid and contains(name(),$item)]
  let $posted-events := $rp/*:status/*:timeline/_[(lower-case(*:name[1])='reviewed preprint posted' or contains(*:name[1],'version')) and starts-with(*:date/data(),$month)]
  where $posted-events
  let $id := $rp/*:msid
  for $event in $posted-events
  let $v := if (contains($event/*:name,'posted')) then '1'
          else substring-after($event/*:name,'version ')
  let $date := $event/date/data()
  let $doi := ('https://doi.org/10.7554/eLife.'||$id||'.'||$v)
  let $xml := fetch:xml(('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-data/master/data/'
                         ||$id
                         ||'/v'
                         ||$v
                         ||'/'
                         ||$id
                         ||'-v'
                         ||$v
                         ||'.xml'))
  where $xml
  let $hhmi-authors := local:hhmi-authors($xml//*:article,false())
  where ($hhmi-authors!='')
  order by $date
  return <record>
           <entry>{'RP version '||$v}</entry>
           <entry>{tokenize($date,'-')[1]}</entry>
           <entry>{replace($doi,'\.\d$','')}</entry>
           <entry>{data($xml//*:article-meta/*:title-group/*:article-title)}</entry>
           <entry>{$hhmi-authors}</entry>
           <entry>new</entry>
         </record>
)
}</csv>

let $hhmi-corr-art := <csv>
<record>
<entry>Publication Type</entry>
<entry>Publication year</entry>
<entry>DOI</entry>
<entry>title</entry>
<entry>HHMI affiliated authors</entry>
<entry>Publication model</entry>
</record>
{
(
  for $x in $latest-articles//*:item
  let $article := collection($x/text())//*:article
  let $title := $article//*:article-meta/*:title-group/*:article-title/data() 
  let $doi := ('https://doi.org/'||$article//*:article-meta/*:article-id[@pub-id-type="doi"][1])
  let $pub-year := $article//*:article-meta//*:pub-date[@date-type=('pub','publication')]/*:year
  let $hhmi-corr-authors := local:hhmi-authors($article,true())
  let $pub-model := if ($article//*:article-meta//*:custom-meta[*:meta-value='prc']) then 'new' 
                    else 'old' 
  order by number($pub-year)
  where ($hhmi-corr-authors!='')
  return <record>
           <entry>VOR</entry>
           <entry>{data($pub-year)}</entry>
           <entry>{$doi}</entry>
           <entry>{$title}</entry>
           <entry>{$hhmi-corr-authors}</entry>
           <entry>{$pub-model}</entry>
         </record>
   ,
   for $item in $rp-json//*:manuscripts/*[not(*:msid)]/text()
  let $rp := $rp-json//*:manuscripts/*[*:msid and contains(name(),$item)]
  let $posted-events := $rp/*:status/*:timeline/_[(lower-case(*:name[1])='reviewed preprint posted' or contains(*:name[1],'version')) and starts-with(*:date/data(),$month)]
where $posted-events
  let $id := $rp/*:msid
  for $event in $posted-events
  let $v := if (contains($event/*:name,'posted')) then '1'
          else substring-after($event/*:name,'version ')
  let $date := $event/date/data()
  let $doi := ('https://doi.org/10.7554/eLife.'||$id||'.'||$v)
  let $xml := fetch:xml(('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-data/master/data/'
                         ||$id
                         ||'/v'
                         ||$v
                         ||'/'
                         ||$id
                         ||'-v'
                         ||$v
                         ||'.xml'))
  where $xml
  let $hhmi-authors := local:hhmi-authors($xml//*:article,true())
  where ($hhmi-authors!='')
  order by $date
  return <record>
           <entry>{'RP version '||$v}</entry>
           <entry>{tokenize($date,'-')[1]}</entry>
           <entry>{replace($doi,'\.\d$','')}</entry>
           <entry>{data($xml//*:article-meta/*:title-group/*:article-title)}</entry>
           <entry>{$hhmi-authors}</entry>
           <entry>new</entry>
         </record>
)
}</csv>

return (
  file:write('/Users/fredatherden/Desktop/hhmi-articles-'||$month||'.csv',$hhmi-art, map{'method':'csv','encoding':'UTF-8'}),
  file:write('/Users/fredatherden/Desktop/hhmi-corr-articles-'||$month||'.csv',$hhmi-corr-art, map{'method':'csv','encoding':'UTF-8'})
)