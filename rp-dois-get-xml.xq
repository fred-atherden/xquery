let $xml-loc := 'https://raw.githubusercontent.com/elifesciences/enhanced-preprints-data/master/data/'
let $xml-dir := '/Users/fredatherden/Desktop/rp-review-xml/'

return (
  if (not(file:exists($xml-dir))) then file:create-dir($xml-dir),
  
  for $x in ('10.1101/2022.03.08.483420',
             '10.1101/2023.01.06.523006',
             '10.1101/2022.12.06.519376',
             '10.1101/2022.11.18.517042')
  let $sub := substring-after($x,'/')
  let $xml := fetch:xml(($xml-loc||$x||'/'||$sub||'.xml'))
  return file:write(($xml-dir||$sub||'.xml'),$xml) 
)

