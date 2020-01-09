for $x in //*:article-meta//*:collab//*:contrib/*:aff
let $d := $x/ancestor::article-meta/*:contrib-group
return insert node $x as last into $d