declare variable $sch := doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/schematron.sch');
declare variable $base-uri := substring-before(base-uri($sch),'/schematron.sch');

for $x in $sch//*:pattern[@id="org-pattern"]//(*:report|*:assert)
let $org-name := substring-before(substring-after($x,"an organism - '"),"' - but there is n")
let $rule-id := $x/parent::*:rule/@id
let $path := concat($base-uri,'/tests/',$rule-id,'/',$x/@id,'/')
let $pass := concat($path,'pass.xml')
let $fail := concat($path,'fail.xml')
let $pass-element := if ($rule-id = 'org-ref-article-book-title') then
                <element-citation publication-type="journal">
                  <article-title> test <italic>{$org-name}</italic> test </article-title>
                </element-citation>
                else 
                <article-meta>
                  <title-group>
                    <article-title> test <italic>{$org-name}</italic> test </article-title>
                  </title-group>
                </article-meta>
                
let $fail-element := if ($rule-id = 'org-ref-article-book-title') then
                <element-citation publication-type="journal">
                  <article-title>{concat(' test ',lower-case($org-name),' test ')}</article-title>
                </element-citation>
                else 
                <article-meta>
                  <title-group>
                    <article-title>{concat(' test ',lower-case($org-name),' test ')}</article-title>
                  </title-group>
                </article-meta>
                
let $pi-content := ('SCHSchema="'||$x/@id||'.sch'||'"') 
let $comment := comment{concat('Context: ',$x/parent::*:rule/@context/string(),'
Test: ',normalize-space($x/@test/string()))}

let $pass-new := 
(processing-instruction {'oxygen'}{$pi-content},
$comment,
  <root xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0">
  <article>
    {$pass-element}
  </article>
</root>)

let $fail-new := 
(processing-instruction {'oxygen'}{$pi-content},
$comment,
<root xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0">
  <article>
    {$fail-element}
  </article>
</root>
)
return
(
  file:write($pass,$pass-new),
  file:write($fail,$fail-new)
)

