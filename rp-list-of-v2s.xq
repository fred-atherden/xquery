let $json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'))
for $rp in $json//*:manuscripts/*[not(*)]
    let $msid := substring-before($rp,'v')
    let $v := substring-after($rp,'v')
    let $timeline := $json//*:manuscripts/*[*:msid=$msid and *:version=$v]/status/timeline
    let $rpv1-event := $timeline/*[matches(lower-case(*:name[1]),'reviewed preprint posted|version 1')]
    let $rpv2-event := $timeline/*[matches(lower-case(*:name[1]),'version 2')]
    where $rpv2-event
    return $msid