(: Go to https://docs.google.com/spreadsheets/d/106_XeDjmuBae7gexOTNzg60lapeqjl2aRn9DzupGyS8/edit#gid=0
   save as CSV and rename to rp-pdfs.csv :)
let $csv := csv:parse(file:read-text('/Users/fredatherden/Downloads/rp-pdfs.csv'))
let $pdf-folder := '/Users/fredatherden/Desktop/rp-pdfs/'
let $data-folder := '/Users/fredatherden/Documents/GitHub/enhanced-preprints-data/data/'

for $entry in $csv//*:record[lower-case(entry[5])=('yes','fixed')]/*:entry[3]
let $msid := substring-before($entry,'.')
let $v := substring-before(substring-after($entry,'.'),'.')
let $pdf-loc :=  $pdf-folder||$entry
let $data-loc := $data-folder||$msid||'/v'||$v||'/'||$msid||'-v'||$v||'.pdf'
where not(file:exists($data-loc))
return file:copy($pdf-loc,$data-loc)