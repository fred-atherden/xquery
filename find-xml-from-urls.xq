let $list := doc('/Users/fredatherden/Desktop/list.xml')

for $x in $list//*:item
let $url := concat('https://gatesopenresearch.org/articles/3-',$x/text(),'/v1/xml')
let $type := fetch:content-type($url)

let $name := concat('gatesopenresearch','-',concat('3-',$x/text()),'.xml')
let $file-path := concat('/Users/fredatherden/Documents/gates-xml/',$name)

return 
if (substring-before($type,';') = 'application/xml') then $url
else ()