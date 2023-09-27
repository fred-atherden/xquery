declare variable $ms-json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'));
declare variable $folder := '/Users/fredatherden/Desktop/assessment-terms/';

for $item in $ms-json//*:manuscripts/*[not(*:msid)]/text()
let $rp := $ms-json//*:manuscripts/*[*:msid and contains(name(),$item)]
let $msid := $rp/*:msid
let $v := $rp/*:version
let $xml := doc($folder||$msid||'v'||$v||'.xml')
let $terms := $xml//*:term
where some $term in $terms satisfies $term='landmark'
return $msid||'v'||$v