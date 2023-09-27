let $list := <list>
    <item><doi>2022-2-11</doi><doi>10.7554/elife.67126</doi><doi>10.1101/770586</doi></item>
    <item><doi>2022-2-10</doi><doi>10.7554/elife.73577</doi><doi>10.1101/2021.08.30.458162</doi></item>
    <item><doi>2022-2-10</doi><doi>10.7554/elife.72096</doi><doi>10.1101/2021.08.02.454720</doi></item>
    <item><doi>2022-2-10</doi><doi>10.7554/elife.71361</doi><doi>10.1101/2021.06.16.448714</doi></item>
    <item><doi>2022-2-9</doi><doi>10.7554/elife.72483</doi><doi>10.1101/2021.08.05.455197</doi></item>
    <item><doi>2022-2-9</doi><doi>10.7554/elife.70164</doi><doi>10.1101/2021.05.13.443991</doi></item>
    <item><doi>2022-2-8</doi><doi>10.7554/elife.68648</doi><doi>10.1101/2021.04.13.439649</doi></item>
    <item><doi>2022-2-8</doi><doi>10.7554/elife.71103</doi><doi>10.1101/2019.12.13.876128</doi></item>
    <item><doi>2022-2-8</doi><doi>10.7554/elife.74365</doi><doi>10.1101/2021.10.15.464551</doi></item>
    <item><doi>2022-2-8</doi><doi>10.7554/elife.73516</doi><doi>10.1101/2021.01.13.426498</doi></item>
    <item><doi>2022-2-8</doi><doi>10.7554/elife.68677</doi><doi>10.1101/2021.04.09.439198</doi></item>
    <item><doi>2022-2-8</doi><doi>10.7554/elife.73439</doi><doi>10.1101/2021.09.10.459761</doi></item>
</list>

for $x in $list//*:item
let $deposit := $x/doi[1]
let $e-doi := $x/doi[2]
let $p-doi := $x/doi[3]
let $e-json := json:parse(fetch:text('https://api.elifesciences.org/articles/'||substring-after($e-doi,'elife.')))
let $vor-pub-date := substring-before($e-json//*:versionDate,'T')
let $e-title := $e-json/*:json/*:title/data()
let $p-json := json:parse(fetch:text('http://api.crossref.org/works/'||$p-doi))
let $p-title := $p-json/*:json/*:message/*:title/data()
let $match := if (lower-case($e-title)=lower-case($p-title)) then 'yes'
              else "no"
let $l-dist := if ($match='yes') then 1
               else strings:levenshtein(lower-case($e-title),lower-case($p-title)) 
return 
<item elife="{$e-doi}" preprint="{$p-doi}" vor-pub-date="{$vor-pub-date}" deposit="{$deposit}" title-match="{$match}" l-dist="{$l-dist}"/>