let $root := '/Users/fredatherden/Documents/ejp-xml/'
let $folders := file:list($root)[.!='.DS_Store']

for $folder in $folders[starts-with(.,'ejp_eLife_2021')]
let $files := file:list($root||$folder)[not(.=('go.xml','.DS_Store')) and ends-with(.,'.xml')]
for $xml in $files
return
try { db:replace('ejp-2021',($folder||$xml),doc($root||$folder||$xml)) }
catch * {update:output($err:code|| ' ' || $err:description)}