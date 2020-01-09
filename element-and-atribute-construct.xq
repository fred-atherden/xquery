declare namespace x="http://www.jenitennison.com/xslt/xspec";
<result xmlns:x="http://www.jenitennison.com/xslt/xspec">

{let $x := doc('/Users/fredatherden/xspec/jats-support/support.sch')

for $y in $x//*:pattern//(*:report|*:assert)
let $name := concat('x:expect-not-',$y/local-name())
return element {$name} {attribute {'id'} {$y/@id}, attribute {'role'} {$y/@role}}}

</result>
