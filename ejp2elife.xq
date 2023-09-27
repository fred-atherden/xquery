declare namespace xlink="http://www.w3.org/1999/xlink";
import module namespace local = 'local' at 'functions.xqm';
declare variable $folder := '/Users/fredatherden/Desktop/ejp-export/';
declare variable $output-folder := '/Users/fredatherden/Desktop/ejp-export/processed/';
declare variable $files := file:list($folder)[ends-with(.,'.zip')];
declare variable $xsl := doc('/Users/fredatherden/Documents/xsl/ejp2elife.xsl');

for $file in $files
  let $xml-filename := (substring-before($file,'.zip')||'.xml')
  let $filepath:= ($folder||$file)
  let $zip := file:read-binary($filepath)
  let $zip-entries :=  archive:entries($zip)
  let $xml := local:parse-ejp(
                 for $entry in $zip-entries[ends-with(., '.xml')]
                 return archive:extract-text($zip, $entry)
               )
  let $new-xml := xslt:transform($xml,$xsl)

return file:write(($output-folder||$xml-filename),$new-xml,
                map {'omit-xml-declaration':'no',
                   'doctype-system':'JATS-archivearticle1.dtd',
                   'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN'}
                )