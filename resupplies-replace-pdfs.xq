let $folder := '/Users/fredatherden/Desktop/resupplies/'
let $updated := ($folder||'updated/')
let $pdf-folder := ($folder||'pdfs/')

for $file in file:list($folder)[ends-with(.,'.zip')]
let $no := substring-before(substring-after($file,'elife-'),'-')
let $new-pdf-loc := $pdf-folder||$no||'.pdf'
let $zip-location := ($folder||$file)
let $zip := file:read-binary($zip-location)
let $zip-pdf := archive:entries($zip)[matches(.,'^elife-\d{5}-v\d\.pdf$')]
let $updated-zip := archive:update($zip,$zip-pdf,file:read-binary($new-pdf-loc))
return file:write-binary(($updated||$file),$updated-zip)