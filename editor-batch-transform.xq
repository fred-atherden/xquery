let $db := 'articles'
let $output-dir := '/Users/fredatherden/Desktop/xsl-check/'
let $xsl := doc('/Users/fredatherden/Documents/xsl/insight.xsl')


for $article in collection('articles')//*:article[@article-type="article-commentary"]
let $file-name := substring-after($article/base-uri(),($db||'/'))
let $new-article := xslt:transform($article,$xsl)
return file:write(
              ($output-dir||$file-name),
              $new-article,
              map {'indent':'no',
                   'omit-xml-declaration':'no',
                   'doctype-system':'JATS-archivearticle1.dtd',
                   'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN'}
                 )