let $dtd := '/Users/fredatherden/Documents/dtds/green-dtd/JATS-archivearticle1-mathml3.dtd'
let $folder := '/Users/fredatherden/Desktop/pre-edit/'

for $file in file:list($folder)[.!='.DS_Store' and .!='pre-report.xml']
let $path := ($folder||$file)
return validate:dtd-report($path,$dtd)
