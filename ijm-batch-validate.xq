import module namespace schematron = "http://github.com/Schematron/schematron-basex";

declare variable $sch := schematron:compile(doc('/Users/fredatherden/Documents/GitHub/jats-support-2/src/support.sch'));

for $x in collection('ijm')//*:article
let $svrl := schematron:validate($x, $sch)
let $ids := ('table_parent-assert-1','table-assert-1','table-wrap-assert-1','tbody_parent-assert-1','td_child-assert-1','th_child-assert-1','thead_parent-assert-1','tr_parent-assert-1')
return 
<item article="{$x/base-uri()}">{
  if ($svrl//(*:successful-report[@id=$ids]|*:failed-assert[@id=$ids])) then $svrl//(*:successful-report[@id=$ids]|*:failed-assert[@id=$ids])
  else ()}
</item>