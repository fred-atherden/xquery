let $sch := doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/schematron.sch')

for $x in $sch//*:rule[@id=('fig-permissions','fig-permissions-check')]//(*:report|*:assert)
return ("`"||$x/@id||"` - "||$x/data())