let $csv := csv:parse(file:read-text('/Users/fredatherden/Downloads/rp-pdfs.csv'))
let $manuscripts :='/Users/fredatherden/Documents/GitHub/enhanced-preprints-client/manuscripts.json'
let $json := json:parse(file:read-text($manuscripts))

let $new-json := copy $copy := $json
                 modify(
                   for $entry in $csv//*:record[lower-case(entry[5])=('yes','fixed')]/*:entry[3]
                   let $msid := substring-before($entry,'.')
                   let $v := substring-before(substring-after($entry,'.'),'.')
                   let $obj := $copy//*:manuscripts/*[*:msid=$msid and *:version=$v]
                   let $pdf-loc := 'https://github.com/elifesciences/enhanced-preprints-data/raw/master/data/'||$msid||'/v'||$v||'/'||$msid||'-v'||$v||'.pdf'
                   where not($obj/*:pdfUrl)
                   return insert node <pdfUrl>{$pdf-loc}</pdfUrl> as last into $obj
                 )
                 return $copy

return file:write($manuscripts,$new-json,map{"method": "json"})