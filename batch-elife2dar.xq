import module namespace local = 'local' at 'functions.xqm';

let $folder := '/Users/fredatherden/Desktop/test-folder'
let $zips := file:list($folder, true(), '*.zip')

for $zip in $zips
return local:elife2dar($folder || '/' || $zip)