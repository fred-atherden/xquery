for $x in //*:article-meta/*:contrib-group/*:aff[not(child::*:label)]
let $n := substring-after($x/@id,'aff')
return insert node <label>{$n}</label> as first into $x
