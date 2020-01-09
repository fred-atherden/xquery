import module namespace schematron = "http://github.com/Schematron/schematron-basex";
declare namespace svrl = 'xmlns="http://purl.oclc.org/dsdl/schematron';

declare variable $dir := '/Users/fredatherden/Documents/GitHub/jats-support-2/tests/cases/';
declare variable $sch := schematron:compile(doc('/Users/fredatherden/Desktop/backup/support.sch'));


let $list := 
<list>{
for $x in file:list($dir)
return 
if ($x='.DS_Store') then ()
else if (ends-with($x,'/')) then for $y in file:list($dir||$x) return <item file="{($dir||$x||$y)}">{doc($dir||$x||$y)}</item>
else <item file="{($dir||$x)}">{doc($dir||$x)}</item>
}</list>

for $x in $list//*:item

let $p-list := 
<list type="php" file="{$x/@file}">{
  for $y in $x//processing-instruction('expected-error')
  let $m :=  substring-before(
      substring-after($y,'message="')
      , '" node="'
    )
    order by $m
  return <item>{$m}</item>
}</list>

let $svrl := schematron:validate($x/descendant::*[1], $sch)

let $svrl-list := 
<list type="svrl" file="{$x/@file}">{
  for $y in $svrl//(*:failed-assert|*:successful-report)
  let $t := normalize-space($y/*:text)
  order by $t
  return <item>{$t}</item>
}</list>

return 
if ($p-list = $svrl-list) then ()
else (<result>{$svrl-list,$p-list}</result>)




