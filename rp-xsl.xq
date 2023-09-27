let $root := '/Users/fredatherden/Documents/GitHub/xslt3-sandbox/'
let $doi-suff := '2022.05.30.22275761'
let $xsl-name := 'add-missing-aff-for-AK-v1'
let $xsl := ($root||'src/'||$doi-suff||'/'||$xsl-name||'.xsl')
let $fixture := ($root||'test/fixtures/'||$doi-suff||'/'||$doi-suff||'.xml')
let $new-xml := xslt:transform(doc($fixture),doc($xsl))
let $folder := $root||'test/'||$doi-suff||'/'||$xsl-name||'/'
return (
  if (not(file:exists($folder))) then file:create-dir($folder),
  file:write(($folder||$doi-suff||'.xml'),$new-xml,
                map {'omit-xml-declaration':'no',
                     'indent':'no',
                   'doctype-system':'JATS-archivearticle1.dtd',
                   'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.2d1 20170631//EN'}
                )
)