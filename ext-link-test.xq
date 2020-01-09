declare namespace xlink="http://www.w3.org/1999/xlink";

let $list := <list xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">
{for $x in collection('articles')//*:ext-link
return if (matches($x/@xlink:href,'^ftp|^http')) then ()
else $x}
</list>

return  file:write('/Users/fredatherden/Desktop/link-list.xml',$list, map {'indent':'yes'})