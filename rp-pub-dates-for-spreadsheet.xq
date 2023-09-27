let $flag := '/Users/fredatherden/Desktop/rp-dois/flag.txt'
let $last-update := if (file:exists($flag)) then xs:date(file:read-text($flag))
                    else xs:date('1970-01-01')

let $json := json:parse(fetch:text('https://raw.githubusercontent.com/elifesciences/enhanced-preprints-client/master/manuscripts.json'))

let $items := 
  for $x in $json//*:manuscripts/*[not(*)]
  let $msid := substring-before($x,'v')
  let $v := substring-after($x,'v')
  let $e := $json//*:manuscripts/*[*:msid=$msid and *:version=$v]
  return
  if ($v='1') then (
    let $pub-date := $e//*:status/*:timeline/*[lower-case(name[1])='reviewed preprint posted' or contains(name[1],'version 1')]/date
    return '10.7554/eLife.'||$msid||'	'||$v||'	'||$pub-date||'	14:00:00'
  )
  else if ($v='2') then (
    let $v1-date := $e//*:status/*:timeline/*[contains(name[1],'version 1')]/date
    let $v2-date := $e//*:status/*:timeline/*[contains(name[1],'version 2')]/date
    return ('10.7554/eLife.'||$msid||'	1	'||$v1-date||'	14:00:00',
            '10.7554/eLife.'||$msid||'	'||$v||'	'||$v2-date||'	14:00:00')
  )
  else (
    let $v1-date := $e//*:status/*:timeline/*[contains(name[1],'version 1')]/date
    let $v2-date := $e//*:status/*:timeline/*[contains(name[1],'version 2')]/date
    let $v3-date := $e//*:status/*:timeline/*[contains(name[1],'version 3')]/date
    return ('10.7554/eLife.'||$msid||'	1	'||$v1-date||'	14:00:00',
            '10.7554/eLife.'||$msid||'	'||$v||'	'||$v2-date||'	14:00:00',
            '10.7554/eLife.'||$msid||'	'||$v||'	'||$v3-date||'	14:00:00')
  )

return (
  for $x in $items
  let $date := tokenize($x,'	')[position()=3]
  where xs:date($date) gt $last-update
  order by $date
  return $x,
  
  let $latest-date := max(for $x in $items return xs:date(tokenize($x,'	')[position()=3]))
  return file:write($flag,$latest-date)
)