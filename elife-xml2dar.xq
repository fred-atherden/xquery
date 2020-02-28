declare namespace xlink="http://www.w3.org/1999/xlink";

declare function local:get-manifest(
    $article,
    $filename as xs:string){
  <dar>
  <documents>
    <document id="manuscript" type="article" path="{$filename}" />
  </documents>
   <assets>
   {(
     for $asset in $article//(*:fig|*:supplementary-material|*:media[@mimemtype="video"])
     let $name := $asset/name()
     return 
     if ($name='fig') then <asset id="{$asset/@id}" type="image/jpeg" path="{$asset/*:graphic[1]/@xlink:href}"/>
     else if ($name='supplementary-material') then <asset id="{$asset/@id}" type="{($asset/media[1]/@mimetype/string()||'/'||$asset/media[1]/@mime-subtype/string())}" path="{$asset/*:media[1]/@xlink:href/string()}"/>
     else <asset id="{$asset/@id}" type="{($asset/@mimetype/string()||'/'||$asset/@mime-subtype/string())}" path="{$asset/@xlink:href/string()}"/>
   )}
   </assets>
</dar>
};


let $db := 'articles'
let $output-dir := '/Users/fredatherden/Desktop/xsl-check/'
let $xsl := doc('/Users/fredatherden/Documents/xsl/insight.xsl')
let $math-xsl := doc('/Users/fredatherden/Documents/GitHub/mml2tex/xsl/invoke-mml2tex.xsl')
for $article in collection('articles')//*:article[@article-type="article-commentary"][base-uri()='/articles/elife-55749-v1.xml']
let $article-id := normalize-space($article//*:article-meta/*:article-id[@pub-id-type="publisher-id"][1])
let $filename := substring-after($article/base-uri(),($db||'/'))
let $dar-filename := (substring-before($filename,'.xml')||'.dar')
let $new-article := xslt:transform(xslt:transform($article,$xsl),$math-xsl)
let $manifest := local:get-manifest($new-article,$filename)
let $json := json:parse(fetch:text('https://api.elifesciences.org/articles/'||$article-id))
let $figs := for $img in $json//*:image[@type="object"]
             let $file := $img/*:source/*:filename/data()
             let $uri := $img/*:source/*:uri/data()
             return
             if ($file = $manifest//*:asset/@path/string()) then fetch:binary($uri)
             else ()

let $dar-entries := (
  <archive:entry format="xml">{$filename}</archive:entry>,
  <archive:entry format="xml">manifest.xml</archive:entry>,
  for $fig in $manifest//*:asset
  return <archive:entry>{$fig/@path/string()}</archive:entry>
  )

return (
      (file:write(
              ($output-dir||$filename),
              $new-article,
              map {'indent':'no',
                   'omit-xml-declaration':'no',
                   'doctype-system':'JATS-archivearticle1.dtd',
                   'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN',
                   'cdata-section-elements':'tex-math'}
                 ),
      file:write(($output-dir||'.manifest.xml'),$manifest)),
                 
 let $dar-contents := (
     file:read-binary($output-dir||$filename),
     file:read-binary($output-dir||'.manifest.xml'),
     $figs)
 let $dar := archive:create($dar-entries,$dar-contents)
 return (
    file:write-binary(($output-dir||$dar-filename), $dar),
    file:delete($output-dir||$filename),
    file:delete($output-dir||'.manifest.xml')
    ) 
)