let $result := <list>{
  for $f in collection('articles')//*:fn[not(@fn-type=('COI-statement','con','conflict','present-address','equal')) and (ancestor::*:author-notes or ancestor::*:sec[@sec-type="additional-information"]) and not(ancestor::*:fn-group[@content-type="ethics-information"])]
  let $id := substring-after(substring-before($f/base-uri(),'-v'),'elife-')
  order by $f/base-uri()
  return 
  if (contains($f,'contributed equally')) then ()
  else if (contains(lower-case($f),'present address')) then ()
  else if (contains(lower-case($f),'current address')) then ()
  else if (contains(lower-case($f),'competing')) then ()
  else if (matches(lower-case($f),'conflicts? of interest')) then ()
  else if (matches(lower-case($f),'united (kingdom|states)| usa$|spain|japan|china|germany|france|singapore|brazil')) then ()
  else <item id="{$id}">{$f}</item>
}</list>

let $values := distinct-values($result//*:item/@id)

for $value in $values
let $x := $result//*:item[@id = $value][1]
return ($x/@id||' - '||$x//*:p)