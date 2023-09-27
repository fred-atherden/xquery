module namespace local = 'local';
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";
declare namespace x="http://www.jenitennison.com/xslt/xspec";
declare namespace xlink="http://www.w3.org/1999/xlink";

declare function local:elife2dar($zip-location){
  let $zip-name := tokenize($zip-location,'/')[last()]

  let $zip := file:read-binary($zip-location)
  let $zip-entries :=  archive:entries($zip)
  let $xml := for $entry in $zip-entries[ends-with(., '.xml')]
             return archive:extract-text($zip, $entry)
  let $article := fn:parse-xml($xml)[descendant::*:article]
  let $article-file-name := ('elife-'||$article//*:article-id[@pub-id-type="publisher-id"]||'.xml')
  
  let $manifest := 
  <dar>
    <documents>
      <document id="manuscript" type="article" path="{$article-file-name}" />
    </documents>
     <assets>
     {(
       for $asset in $article//(*:fig|*:supplementary-material|*:media[@mimemtype="video"])
       let $name := $asset/name()
       return 
       if ($name='fig') then <asset id="{$asset/@id}" type="{($asset/graphic[1]/@mimetype/string()||'/'||$asset/graphic[1]/@mime-subtype/string())}" path="{$asset/*:graphic[1]/@xlink:href/string()}"/>
       else if ($name='supplementary-material') then <asset id="{$asset/@id}" type="{($asset/media[1]/@mimetype/string()||'/'||$asset/media[1]/@mime-subtype/string())}" path="{$asset/*:media[1]/@xlink:href/string()}"/>
       else <asset id="{$asset/@id}" type="{($asset/@mimetype/string()||'/'||$asset/@mime-subtype/string())}" path="{$asset/@xlink:href/string()}"/>
     )}
     </assets>
  </dar>

  let $manifest-location := (substring-before($zip-location,$zip-name)||'manifest.xml') 


  return (
    file:write($manifest-location,$manifest),


    let $dar-entries := (<archive:entry format="xml">manifest.xml</archive:entry>,$zip-entries)
    let $dar-contents := (file:read-binary($manifest-location),archive:extract-binary($zip))
    let $dar-location := (substring-before($zip-location,'.zip')||'.dar')

    let $dar := archive:create($dar-entries,$dar-contents)

    return (
      file:write-binary($dar-location, $dar),
      file:delete($manifest-location)
      ) 
  )
};

declare function local:parse-ejp($input as xs:string?){
  let $license-type := substring-before(substring-after($input,'<license xlink:href="'),'"')
  let $permissions := 
      <permissions>{
      (parse-xml-fragment(substring-before(substring-after($input,'<permissions>'),'<license')),
      if (contains($license-type,'4.0')) then
      <license license-type="open-access" xlink:href="http://creativecommons.org/licenses/by/4.0/">
            <license-p>This article is distributed under the terms of the Creative Commons Attribution License, which permits unrestricted use and redistribution provided that the original author and source are credited.</license-p>
          </license>
      else if (contains($license-type,'3.0')) then
      <license license-type="open-access" xlink:href="http://creativecommons.org/licenses/by/3.0/">
            <license-p>This article is distributed under the terms of the Creative Commons Attribution License, which permits unrestricted use and redistribution provided that the original author and source are credited.</license-p>
          </license>
      else <license xlink:href="http://creativecommons.org/publicdomain/zero/1.0/">
    <license-p>This is an open-access article, free of all copyright, and may be freely reproduced, distributed, transmitted, modified, built upon, or otherwise used by anyone for any lawful purpose. The work is made available under the <ext-link ext-link-type="uri" xlink:href="http://creativecommons.org/publicdomain/zero/1.0/">Creative Commons CC0</ext-link> public domain dedication.</license-p>
      </license>)
      }</permissions>
  let $history-link := substring-before(substring-after($input,'<ext-link ext-link-type="url" xlink:href="'),'"')
  let $article-history := 
     <fn-group content-type="article-history">
        <title>Preprint</title>
        <fn fn-type="other"/>
        <ext-link ext-link-type="uri" xlink:href="{$history-link}"/>
      </fn-group>
  let $article-meta := 
      <article-meta>{
        (parse-xml-fragment(substring-before(substring-after($input,'<article-meta>'),'<permissions>')),
        $permissions,
        parse-xml-fragment(substring-before(substring-after($input,'</permissions>'),'<fn-group content-type="article-history">')),
        $article-history,
        parse-xml-fragment(('<files>'||substring-before(substring-after($input,'<files>'),'</article-meta>'))))
      }</article-meta>
let $journal-meta := parse-xml-fragment(substring-before(substring-after($input,'<front>'),'<article-meta>'))
let $front := <front>{$journal-meta,$article-meta}</front>
let $article-type :=  substring-before(substring-after($input,'<article article-type="'),'"')
let $article := <article article-type="{$article-type}" dtd-version="1.1" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">{$front}</article>
return ($article)
  
};