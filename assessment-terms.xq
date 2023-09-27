(: RUN write-assessment-terms-to-folder.xq FIRST :)
declare variable $ms-json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'));
declare variable $folder := '/Users/fredatherden/Desktop/assessment-terms/';
declare variable $month := '2023-09';

let $terms :=  for $item in $ms-json//*:manuscripts/*[not(*:msid)]/text()
               let $rp := $ms-json//*:manuscripts/*[*:msid and contains(name(),$item)]
               let $msid := $rp/*:msid
               let $v := $rp/*:version
               let $xml := doc($folder||$msid||'v'||$v||'.xml')
               let $pub-month := string-join(tokenize($xml//*:terms/@pub-date,'-')[position()=(1,2)],'-')
               where $pub-month le $month
               return $xml//*:term

for $term in distinct-values($terms)
let $count := count($terms[.=$term])
return $term||': '||$count