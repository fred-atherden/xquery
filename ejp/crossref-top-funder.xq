declare variable $folder := "/Users/fredatherden/Desktop/funder-data/";

let $list := <list>{
    for $file in file:list($folder)[ends-with(.,'.xml')]
    let $xml := doc($folder||$file)
    for $x in $xml//*:items/*
    let $pub-year := $x/*:published-online/*/*/*[matches(.,'\d{4}')]
    order by $x/*:DOI
    return 
    (: like this:
    <item pub-year="2018" doi="10.7554/elife.38770">
      <funder doi="10.13039/100000002">
        <name>National Institutes of Health</name>
          <award type="array"><_>NIBIB intramural research program</_></award>
      </funder>
      <funder doi="10.13039/100000011">
        <name>Howard Hughes Medical Institute</name>
        <award type="array"/>
      </funder>
    </item>:)
    <item pub-year="{$pub-year}" doi="{$x/*:DOI}">{
      for $y in $x//*:funder/*
      let $doi := $y/*:DOI
      return 
      if ($doi) then <funder asserted-by="{$y/*:doi-asserted-by}" doi="{$doi}">{$y/*:name,$y/*:award}</funder>
      else <funder>{$y/*:name,$y/*:award}</funder>
    }</item>
  }</list>

for $d in distinct-values($list//*:item/*:funder/@doi)
let $name := $list/descendant::*:item[*:funder[@doi=$d]][1]/*:funder[@doi=$d][1]/*:name/text()
let $link := ('=HYPERLINK("'||$d||'","'||$name||'")')
let $count := count($list//*:item[*:funder[@doi=$d]])
order by $count descending
return ($link||'	'||$count)