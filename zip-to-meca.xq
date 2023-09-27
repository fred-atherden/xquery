declare namespace xlink="http://www.w3.org/1999/xlink";
declare variable $dir := '/Users/fredatherden/Desktop/rp-xml/';

for $file in file:list($dir)[ends-with(.,'.zip')]
let $zip := file:read-binary($dir||$file)
let $zip-entries := archive:entries($zip)
let $xml := for $entry in $zip-entries[ends-with(., '.xml')]
            return archive:extract-text($zip, $entry)
let $article := fn:parse-xml($xml)[descendant::*:article]

let $manifest := <manifest xmlns="http://manuscriptexchange.org" version="1.0">
  <item type="article">
    <title>{$article//*:article-meta/*:article-title/(*|text())}</title>
    <instance media-type="application/xml" href="{$zip-entries[ends-with(.,'.xml')]/tokenize(.,'/')[last()]}"/>
    <instance media-type="application/pdf" href="{$zip-entries[ends-with(.,'.pdf')]/tokenize(.,'/')[last()]}"/>
  </item>
  <item id="transfer" type="transfer-details">
    <title>MECA Transfer Info</title>
    <instance media-type="application/meca-xfer+xml" href="transfer.xml"/>
  </item>
  {
    for $x in $article//*[name()=('fig','supplementary-material','table-wrap','inline-formula','disp-formula')]
    let $m := $x/*[name()=('inline-graphic','graphic','media')][1]
    where $m
    let $type := switch ($x/name()) 
      case "fig" return "figure"
      case "table-wrap" return "table"
      case "inline-formula" return "equation"
      case "disp-formula" return "equation"
      default return "supplement" 
    let $mimetype := if ($m/@mimetype and $m/@mime-subtype) then ($m/@mimetype||'/'||$m/@mime-subtype)
                     else (
                       switch(tokenize($x/*[name()=('graphic','media')]/@*:href,'\.')[last()])
                         case 'tif' return 'image/tiff'
                         case 'tiff' return 'image/tiff'
                         case 'gif' return 'image/gif'
                         case 'jpg' return 'image/jpeg'
                         case 'docx' return 'application/docx'
                         case 'zip' return 'application/zip'
                         case 'xlsx' return 'application/vnd.ms-excel'
                         case 'xml' return 'application/xml'
                         case 'mpeg' return 'video/mpeg'
                         case 'mp4' return 'video/mp4'
                         default return 'application/octet-stream'
                     )
    
    return 
    <item id="{$x/@id}" type="{$type}">{
      if ($x/*:label) then <title>{$x/*:label[1]/(*|text())}</title>,
      <instance media-type="{$mimetype}" href="{$m/@*:href}"/>
  }</item>
  }
</manifest>

let $transfer := 
<transfer xmlns="http://www.manuscriptexchange.org" version="1.0">
<source>
<service-provider>
<provider-name>Exeter PreMedia</provider-name>
</service-provider>
<publication type="preprint">
<title>{$article//*:journal-meta/*:journal-title/(*|data())}</title>
<acronym>{$article//*:journal-meta/*:abbrev-journal-title/(*|data())}</acronym>
</publication>
</source>
<destination>
<service-provider>
<provider-name>EPP platform</provider-name>
</service-provider>
<publication type="journal">
<title>eLife</title>
<acronym>eLife</acronym>
</publication>
</destination>
</transfer>


return (
  file:write($dir||'manifest.xml',$manifest, map {'indent':'yes',
                   'omit-xml-declaration':'no',
                   'doctype-system':'http://schema.highwire.org/public/MECA/v0.9/Manifest/Manifest.dtd'}),
  file:write($dir||'transfer.xml',$transfer, map {'indent':'yes',
                   'omit-xml-declaration':'no',
                   'doctype-system':'http://schema.highwire.org/public/MECA/v0.9/Transfer/Transfer.dtd'}),
  
  let $meca-entries := (<archive:entry format="xml">manifest.xml</archive:entry>,
                        <archive:entry format="xml">transfer.xml</archive:entry>,
                        $zip-entries)
  let $meca-contents := (file:read-binary($dir||'manifest.xml'),
                         file:read-binary($dir||'transfer.xml'),
                         archive:extract-binary($zip))                       
  let $meca := archive:create($meca-entries,$meca-contents)
  
  return (
    file:write-binary($dir||substring-before($file,'.zip')||'-meca.zip', $meca),
    file:delete($dir||'manifest.xml'),
    file:delete($dir||'transfer.xml')
  )
  
)