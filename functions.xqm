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