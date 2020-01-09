declare namespace xlink="http://www.w3.org/1999/xlink";


let $file := doc('/Users/fredatherden/Documents/GitHub/XML-mapping/elife-00666.xml')

for $x in $file
let $c := copy $copy := $file
modify(
  for $y in $copy//*:table-wrap[@id="keyresource"]//*:td[matches(.,'PMID:')]
  let $id := substring-after($y,'PMID:')
  let $url := concat('https://www.ncbi.nlm.nih.gov/pubmed/',$id)
  return 
  replace node $y with <td>PMID:<ext-link ext-link-type="uri" xlink:href="{$url}">{$id}</ext-link></td>
  
)
return $copy

return file:write('/Users/fredatherden/Desktop/elife-00666.xml',$c,map{'indent':'no'})