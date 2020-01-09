declare function local:translate($input)
{
 replace(replace(translate($input,'àáâãäåçčèéêěëħìíîïłñňòóôõöőøřšśşùúûüýÿž','aaaaaacceeeeehiiiilnnooooooorsssuuuuyyz'),'æ','ae'),'ß','ss')

};

for $x in collection('articles')//*:article


let $a-list := <list>{
 for $y in $x//*:article-meta//*:contrib[@contrib-type="author"]
 return 
 for $c in $y//*:surname
       return <item>{local:translate(lower-case($c))}</item>
}</list>


let $f-list := <list>{
  for $f in $x//*:article-meta/*:funding-group//*:surname
  return <item>{local:translate(lower-case($f))}</item>
}</list>

return
  for $z in $f-list//*:item
  return 
    if (not($a-list//*:item)) then ()
    else if ($z = $a-list//*:item) then ()
    else $x/base-uri() 