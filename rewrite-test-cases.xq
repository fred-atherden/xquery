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
let $svrl := schematron:validate($x/descendant::*[1], $sch)
let $new := 
copy $copy := $x
modify(
  for $m in $copy//processing-instruction('expected-error')
  return delete node $m,
  
  for $z in $svrl//(*:failed-assert|*:successful-report)
  let $t := normalize-space($z/*:text) 
  return insert node 
    processing-instruction{'expected-error'}{('message="'||$t||'" node="'||$z/@location||'"')} 
  before $copy/descendant::*[1], 
  
  for $n in $copy/descendant::*[1]
  return insert node '&#xa;' before $n
)
return $copy
return $new/(*|text()|processing-instruction())




