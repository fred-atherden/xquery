declare namespace xlink="http://www.w3.org/1999/xlink";
let $root := '/Users/fredatherden/Desktop/prc-export-files/'
let $temp-dir := ($root||'temp/')
let $output-dir := ($root||'output/')
let $json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'))
let $manuscripts := tokenize(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-data/master/manuscripts.txt'),'\n')

for $file in file:list($root)[ends-with(.,'.zip')]
let $zip := file:read-binary($root||$file)
let $zip-entries :=  archive:entries($zip)
let $xml-filename := replace($file,'.zip','')||'/'||replace($file,'.zip','.xml')

let $xml := for $entry in $zip-entries[.=$xml-filename]
            return archive:extract-text($zip, $entry)
let $article := fn:parse-xml($xml)[descendant::*:article]
let $msid := $article//*:article-id[@pub-id-type="publisher-id"]/data()
let $timeline := for $rp in $json//*:manuscripts/*[not(*) and contains(.,$msid)]
                    let $v := substring-after($rp,'v')
                    return $json//*:manuscripts/*[*:msid=$msid and *:version=$v]/status/timeline 
let $preprint-doi := for $x in $manuscripts[starts-with(.,$msid)][1]
                     return tokenize(substring-after($x,': '),',')[last()]
let $sent4rev := $timeline/*[lower-case(name)='sent for peer review']/date/data()
let $preprint := $timeline/*[starts-with(lower-case(name),'posted to')]/date/data()
let $rpv1 := $timeline/*[matches(lower-case(name),'reviewed preprint posted|version 1')]/date/data()
let $rpv2 := $timeline/*[matches(lower-case(name),'version 2')]/date/data()

let $new-xml := copy $copy := $article
                modify(
                  
                  if ($copy//*:subj-group[@subj-group-type="display-channel"]/subject[contains(.,'VOR')]) then replace node $copy//*:subj-group[@subj-group-type="display-channel"]/subject[contains(.,'VOR')]
                          with <subject>{substring-before($copy//*:subj-group[@subj-group-type="display-channel"]/subject,'(VOR')}</subject>,
                  
                   for $x in $copy//*:sub-article//*:br
                   return replace node $x with <break/>,
                   
                   for $x in $copy//*:sub-article[@article-type="author-comment"]//*:front-stub//*:role[not(@specific-use)]
                   return insert node attribute specific-use {'author'} into $x,
                   
                   let $msas := distinct-values($copy//*:article-categories/*:subj-group[@subj-group-type="heading"]/*:subject)
                   for $msa in $msas
                   let $count := count($copy//*:article-categories/*:subj-group[@subj-group-type="heading" and *:subject=$msa])
                   where $count gt 1
                   return delete node $copy//*:article-categories/*:subj-group[@subj-group-type="heading" and *:subject=$msa][1],
                   
                   let $kwds := distinct-values($copy//*:kwd-group[@kwd-group-type="research-organism"]/*:kwd)
                   for $kwd in $kwds
                   let $count := count($copy//*:kwd-group[@kwd-group-type="research-organism"]/*:kwd[.=$kwd])
                   where $count gt 1
                   return delete node $copy//*:kwd-group[@kwd-group-type="research-organism"]/*:kwd[.=$kwd][1],
                   
                   let $assess-auth := $copy//*:sub-article[@article-type="editor-report"]/*:front-stub//*:contrib[@contrib-type="author"]
                   let $rev-editor := $copy//*:article-meta//*:contrib[@contrib-type="assoc_ed"]
                   return if ($assess-auth/*:name/*:given-names != $rev-editor/*:name/*:given-names and
                             $assess-auth/*:name/*:surname != $rev-editor/*:name/*:surname)
                             then (
                               replace node $assess-auth with 
                               <contrib contrib-type="author">
                                 {$rev-editor/*:name}
                                 <role specific-use="editor">Reviewing Editor</role>
                                 { $rev-editor/*:aff}
                               </contrib>
                             ),
                  
                   for $x in $copy//*:sub-article//*:list[not(@list-type) or @list-type!="order"]/*:list-item[not(*:p)]
                   return replace node $x with <list-item><p>{$x/(*|text())}</p></list-item>,
                  
                   for $x in $copy//*:sub-article//*:list[@list-type="order"]
                   let $start := if ($x/@start) then number($x/@start)-1 
                                 else 0
                   let $ps := for $y in $x/*:list-item
                              let $pos := count($y/parent::*/*:list-item) - count($y/following-sibling::list-item)
                              let $marker := string($start + $pos)||'. '
                              return if ($y/*:p) then <list-item><p>{($marker,$y/(text()|*[name()!=p]|*:p/(text()|*)))}</p></list-item>
                              else <list-item><p>{($marker,$y/(text()|*))}</p></list-item>
                   return replace node $x with $ps,
                  
                  let $history := <history><date date-type="sent-for-review" iso-8601-date="{$sent4rev}">
                                    <day>{tokenize($sent4rev,'-')[last()]}</day>
                                    <month>{tokenize($sent4rev,'-')[position()=2]}</month>
                                    <year>{tokenize($sent4rev,'-')[position()=1]}</year>
                                  </date></history>
                  return if ($copy//*:history) then replace node $copy//*:history with $history
                  else insert node $history after $copy//article-meta/*:elocation-id,
                
                let $pub := <pub-history>
                <event>
                    <event-desc>This manuscript was published as a preprint.</event-desc>
                    <date date-type="preprint" iso-8601-date="{$preprint}">
                        <day>{tokenize($preprint,'-')[last()]}</day>
                        <month>{tokenize($preprint,'-')[position()=2]}</month>
                        <year>{tokenize($preprint,'-')[position()=1]}</year>
                    </date>
                    <self-uri content-type="preprint" xlink:href="{'https://doi.org/'||$preprint-doi}"/>
                </event>
                <event>
                    <event-desc>This manuscript was published as a reviewed preprint.</event-desc>
                    <date date-type="reviewed-preprint" iso-8601-date="{$rpv1}">
                        <day>{tokenize($rpv1,'-')[last()]}</day>
                        <month>{tokenize($rpv1,'-')[position()=2]}</month>
                        <year>{tokenize($rpv1,'-')[position()=1]}</year>
                    </date>
                    <self-uri content-type="reviewed-preprint" xlink:href="{'https://doi.org/10.7554/eLife.'||$msid||'.1'}"/>   
                </event>
                {
                  if ($rpv2) then (
                    <event>
                    <event-desc>The reviewed preprint was revised.</event-desc>
                     <date date-type="reviewed-preprint" iso-8601-date="{$rpv2}">
                        <day>{tokenize($rpv2,'-')[last()]}</day>
                        <month>{tokenize($rpv2,'-')[position()=2]}</month>
                        <year>{tokenize($rpv2,'-')[position()=1]}</year>
                    </date>
                    <self-uri content-type="reviewed-preprint" xlink:href="{'https://doi.org/10.7554/eLife.'||$msid||'.2'}"/>  
                </event>   
                  )
                }
            </pub-history>
            
            return insert node $pub before $copy//*:article-meta/*:permissions
                )
                return $copy


return (
  if (file:exists($output-dir)) then () else file:create-dir($output-dir),
  file:create-dir($temp-dir),
  archive:extract-to($temp-dir,$zip),
  file:write(($temp-dir||$xml-filename),$new-xml, map{
                  'indent':'no',
                  'omit-xml-declaration':'no'}),
  let $new-zip := archive:create-from($temp-dir)
  return file:write-binary($output-dir||$file,$new-zip),
  file:delete($temp-dir,true())
)