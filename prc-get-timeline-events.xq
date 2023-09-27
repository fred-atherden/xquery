let $msids := ('84338','84792')

let $json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'))
let $manuscripts := tokenize(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-data/master/manuscripts.txt'),'\n')

for $msid in $msids
let $timeline := for $rp in $json//*:manuscripts/*[not(*) and contains(.,$msid)]
                    let $v := substring-after($rp,'v')
                    return $json//*:manuscripts/*[*:msid=$msid and *:version=$v]/status/timeline 
let $preprint-doi := for $x in $manuscripts[starts-with(.,$msid)][1]
                     return tokenize(substring-after($x,': '),',')[last()]
let $sent4rev := $timeline/*[lower-case(name)='sent for peer review']/date/data()
let $preprint := $timeline/*[starts-with(lower-case(name),'posted to')]/date/data()
let $rpv1 := $timeline/*[matches(lower-case(name),'reviewed preprint posted|version 1')]/date/data()
let $rpv2 := $timeline/*[matches(lower-case(name),'version 2')]/date/data()

return string-join(($msid,
                    '	Sent for review: '||$sent4rev,
                    '	Preprint posted date: '||$preprint||' Link: https://doi.org/'||$preprint-doi,
                    '	Reviewed preprint posted date: '||$preprint||' Link: https://doi.org/10.7554/eLife.'||$msid||'.1',
                    if ($rpv2) 
                     then '	Reviewed preprint revised: '||$preprint||' Link: https://doi.org/10.7554/eLife.'||$msid||'.2'
                    else ()
                   ),
                  '&#xA;')
                     