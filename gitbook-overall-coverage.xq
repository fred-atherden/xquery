let $sch := doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/schematron.sch')

let $overall := count($sch//(*:report|*:assert))
let $done := count($sch//(*:report[@see]|*:assert[@see]))
let $percentage := round(($done div $overall) * 100)

return ($percentage||'% ('||$done||' out of '||$overall||')')