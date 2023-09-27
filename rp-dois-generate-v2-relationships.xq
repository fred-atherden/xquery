declare namespace rel = 'http://www.crossref.org/relations.xsd';
let $articles := <list>
<article id="88468" version="1"/>
<article id="86191" version="1"/>
<article id="88733" version="1"/>
<article id="88275" version="1"/>
<article id="88900" version="1"/>
<article id="88279" version="1"/>
<article id="88521" version="1"/>
<article id="87930" version="1"/>
<article id="89371" version="1"/>
<article id="87238" version="1"/>
<article id="89093" version="1"/>
<article id="88782" version="1"/>
<article id="87616" version="2"/>
</list>

let $xml-dir := '/Users/fredatherden/Desktop/rp-dois/'

for $x in $articles//*:article[@version!='1']
let $version := $x/@version
let $id := $x/@id
let $version-file := file:list($xml-dir||'version/')[contains(.,$id||'_'||$version)]
let $version-xml := doc($xml-dir||'version/'||$version-file)
let $has-version-rel := 
<rel:related_item>
<rel:intra_work_relation identifier-type="doi" relationship-type="hasVersion">{'10.7554/eLife.'||$id||'.'||string(number($version)-1)}</rel:intra_work_relation>
</rel:related_item>
let $new-version := 
    copy $copy := $version-xml
    modify(
      insert node $has-version-rel as last into $copy//rel:program
    )
    return $copy

let $concept-file := file:list($xml-dir||'other/')[contains(.,'posted_content-'||$id)]
let $concept-xml := doc($xml-dir||'other/'||$concept-file)
let $new-concept := 
    copy $copy := $concept-xml
    modify(
      insert node $has-version-rel as last into $copy//rel:program
    )
    return $copy

let $minimal := 
    copy $copy := $concept-xml
    modify(
      replace node $copy//rel:program with <rel:program/>,
      
      let $timestamp := $copy//*:timestamp
      let $dateTime := xs:dateTime(replace($timestamp,'(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})', '$1-$2-$3T$4:$5:$6'))
      (:Remove one second from datetime in original format:)
      let $new-timestamp := format-dateTime(($dateTime - xs:dayTimeDuration('PT1S')),'[Y0001][M01][D01][H][m01][s01]')
      
      return (
        replace node $copy//*:timestamp with <timestamp>{$new-timestamp}</timestamp>,
        replace node $copy//*:doi_batch_id with <doi_batch_id>{'elife-crossref-posted_content-'||$id||'_'||$version||'-'||$new-timestamp}</doi_batch_id>
      )  
    )
    return $copy


return (
  file:write(($xml-dir||'version/'||$version-file),$new-version),
  file:write(($xml-dir||'version/'||$concept-file),$minimal),
  file:write(($xml-dir||'other/'||$concept-file),$new-concept)
)