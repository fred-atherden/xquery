(: Update for this spreadsheet https://docs.google.com/spreadsheets/d/1TeLPe1mqQjzu5mfbIsyBqFQNfqlq9RfamhQ-ul7Sy3o/edit :)
(: e.g. all RPv1s posted before Nov-2023 :)
let $cutoff-date :=  xs:date('2023-11-01')
let $json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'))
for $rp in $json//*:manuscripts/*[*]
    let $msid := $rp/*:msid
    let $v := $rp/*:version
    where $v = '1'
    let $timeline := $rp/*:status/*:timeline
    let $rpv1-event := $timeline/*[matches(lower-case(*:name[1]),'reviewed preprint posted|version 1')]
    let $d := $rpv1-event/*:date
    order by $d
    where $rpv1-event and (xs:date($d) lt $cutoff-date)
    
    return '=HYPERLINK("https://elifesciences.org/reviewed-preprints/'||$msid||'v1", "'||$msid||'")	'||$d