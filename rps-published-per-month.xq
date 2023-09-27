declare variable $month := '2023-08';

let $json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'))

let $latest := $json//*:manuscripts/*[not(*)]/data()


let $v1-events := count(
                    for $rp in $json//*:manuscripts/*[*]
                    let $msidvd := $rp/msid||'v'||$rp/version
                    where $msidvd = $latest
                    let $v1-date := $rp/status/timeline/*[starts-with(*:date[1],$month) and matches(lower-case(*:name[1]),'reviewed preprint posted|version 1')]
                    where $v1-date
                    return $v1-date
                  )

let $v2-events :=  count(
                    for $rp in $json//*:manuscripts/*[*]
                    let $msidvd := $rp/msid||'v'||$rp/version
                    where $msidvd = $latest
                    let $v2-date := $rp/status/timeline/*[starts-with(*:date[1],$month) and matches(lower-case(*:name[1]),'version 2')]
                    where $v2-date
                    return $v2-date
                  )

let $v3-events :=  count(
                    for $rp in $json//*:manuscripts/*[*]
                    let $msidvd := $rp/msid||'v'||$rp/version
                    where $msidvd = $latest
                    let $v3-date := $rp/status/timeline/*[starts-with(*:date[1],$month) and matches(lower-case(*:name[1]),'version 3')]
                    where $v3-date
                    return $v3-date
                  )

return $v1-events + $v2-events + $v3-events||' Reviewed preprints were published ('||$v1-events||' first version; '||$v2-events||' second version; '||$v3-events||' third version)'