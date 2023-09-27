let $xml := doc('/Users/fredatherden/Downloads/86784.xml')

return <contrib-group xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">{
  for $x in $xml//*:article-meta//*:contrib-group/*:contrib[@contrib-type="author"]
  let $aff-nodes := for $y in $x/*:xref[@ref-type="aff"]
                    let $aff := $xml//*:article-meta//*:aff[@id=$y/@rid]
                    return 
                    <aff>{
                      $aff//*:institution,
                      $aff/*:addr-line,
                      $aff//*:country
                    }</aff>
  return ($x/*:name,<role specific-use="author">Author</role>,$aff-nodes)
}</contrib-group>