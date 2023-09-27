declare variable $folder := '/Users/fredatherden/Documents/ejp-export/';
declare variable $export-folder := ($folder||'fixed/');

declare function local:export($xml, $id as xs:string){
  if ($xml instance of node()) then file:write($export-folder||$id||'.xml',$xml)
  (: text files may have to be fixed manually :)
  else file:write($export-folder||$id||'-text.xml',$xml)
};

for $file in file:list($folder)[ends-with(.,'.xml')]
order by $file
let $path := $folder||$file
let $text := file:read-text($path,"UTF-8",true())
let $fixed-string := replace(replace(replace(replace(replace($text,'>\s*\n\s*<front>',' xmlns:xlink="http://www.w3.org/1999/xlink">
  <front>'),'&amp;#00A9;','&#x00A9;'),'\s&amp;\s',' &amp;amp; '),'&amp;acc=','&amp;amp;acc='),'&amp;mdash;','&#x2014;')
let $fixed := if (matches($fixed-string,'xlink:href=[^"]* ')) then (
                 let $result := analyze-string($fixed-string,'xlink:href=[^"]* ')
                 let $new-result := copy $copy := $result
                                    modify(
                                      for $x in $copy//*:match
                                      return 
                                      replace value of node $x with 'xlink:href="'||
                                                               substring-before(substring-after($x,'='),' ')||
                                                               '" '
                                    )
                                    return $copy
                 return string-join($new-result/*,'')
              )
              else $fixed-string
let $xml := try {
              parse-xml($fixed)
            }
            catch * {
              $fixed
            }
let $id := analyze-string($file,'\d{5}')//*:match/string()
            
return (
  if (file:exists($export-folder)) then local:export($xml, $id)
  else (
    file:create-dir($export-folder),
    local:export($xml, $id)
  )
)