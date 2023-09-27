let $filepath := '/Users/fredatherden/Desktop/eLife-VOR-RA-2023-86617/eLife-VOR-RA-2023-86617.xml'
let $xml := doc($filepath)

let $fixed := 
  copy $copy := $xml
  modify (
    for $x in $copy//*:sub-article[@article-type="author-comment"]//*:list[@list-type="order"]
    let $start := if ($x/@start) then number($x/@start)-1 
                  else 0
    let $ps := for $y in $x/*:list-item
               let $pos := count($y/parent::*/*:list-item) - count($y/following-sibling::list-item)
               let $marker := string($start + $pos)||'. '
               return <p>{($marker,$y/(text()|*))}</p>
    return replace node $x with $ps
   )
  return $copy
  
return file:write($filepath,$fixed)