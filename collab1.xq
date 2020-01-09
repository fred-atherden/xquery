for $x in //*:article-meta//*:collab//*:contrib[*:aff]
let $n := (count($x/parent::*:contrib-group/*:contrib) - count($x/following-sibling::*:contrib)) + 1
let $aff := $x/*:aff
return (insert node <xref ref-type="aff" rid="{('aff'||$n)}">{$n}</xref> as last into $x,
        insert node attribute id {('aff'||$n)} as first into $aff)