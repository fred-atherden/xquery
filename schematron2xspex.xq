declare namespace x="http://www.jenitennison.com/xslt/xspec";
declare namespace sch="http://purl.oclc.org/dsdl/schematron";
declare variable $sch := doc('../xspec/schematron.sch');

declare function local:get-id($rule){
  if ($rule/@id) then $rule/@id
  else if ($rule/parent::sch:pattern/@id) then
    let $p := $rule/parent::sch:pattern[@id]
    let $pos := count($p/sch:rule) - count($rule/following-sibling::sch:rule)
    return concat($rule/parent::sch:pattern/@id,$pos)
  else generate-id($rule)
};


<x:description xmlns:x="http://www.jenitennison.com/xslt/xspec" schematron="support.sch">
  <x:scenario >{
    for $x in $sch//sch:rule
    let $id := local:get-id($x)  
    return
    <x:scenario>
    </x:scenario>
  
  }</x:scenario>
</x:description>

