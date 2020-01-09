declare namespace xlink="http://www.w3.org/1999/xlink";

let $file-loc := '/Users/fredatherden/Desktop/elife-52628-vor-r1/elife-52628.xml'
let $filename := tokenize($file-loc,'/')[last()]
let $file := doc($file-loc)

let $manifest := <dar>
  <documents>
    <document id="manuscript" type="article" path="{$filename}" />
  </documents>
   <assets>
   {(
     for $asset in $file//(*:fig|*:supplementary-material|*:media[@mimemtype="video"])
     let $name := $asset/name()
     return 
     if ($name='fig') then <asset id="{$asset/@id}" type="{($asset/graphic[1]/@mimetype/string()||'/'||$asset/graphic[1]/@mime-subtype/string())}" path="{$asset/*:graphic[1]/@xlink:href/string()}"/>
     else if ($name='supplementary-material') then <asset id="{$asset/@id}" type="{($asset/media[1]/@mimetype/string()||'/'||$asset/media[1]/@mime-subtype/string())}" path="{$asset/*:media[1]/@xlink:href/string()}"/>
     else <asset id="{$asset/@id}" type="{($asset/@mimetype/string()||'/'||$asset/@mime-subtype/string())}" path="{$asset/@xlink:href/string()}"/>
   )}
   </assets>
</dar>

return $manifest