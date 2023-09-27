let $db := 'ejp-2021'

let $list := <list>{
  for $x in collection($db)//*:xml//*:version
  let $ms-no := $x/*:manuscript-number/data()
  let $no := substring(tokenize($ms-no,'-')[matches(.,'\d{5}')],1,5)
  let $corr-author-id := $x/*:authors/*:author[*:is-corr='true']/*:author-person-id
  let $corr-email := $x/ancestor::*:xml/*:people/person[*:person-id=$corr-author-id]/*:email
  let $stages := $x/*:history/*:stage
  let $emails := 
          for $email in $x/*:emails/*:email[*:email-from='editorial@elifesciences.org' and *:email-to=$corr-email]
          let $message := $email/*:email-message
          where matches($message,' [Dd]ata ') and not(matches($message,'Thank you for (submitting|sending) your|Thank you for choosing to (submit|send) your') and not(contains($message,'writing to follow up on the letter below, to see if you have any questions about the evaluation summary or public reviews')))
          return $email
  let $email-count := count($emails)
  return <item id="{$no}" ms-no="{$ms-no}" count="{$email-count}"/>
}</list>


let $new-list := <list>{
  for $x in distinct-values($list//*:item/@id)
  order by $x
  let $items := $list//*:item[@id=$x]
  let $count := sum($items/number(@count))
  return <item id="{$x}" count="{$count}"/>
}</list>

let $article-count := count($new-list//*:item)
let $height := $article-count * 30
let $width := (max($new-list//*:item/@count) * 10) + 80

let $svg := <svg xmlns="http://www.w3.org/2000/svg" height="{$height}" width="{$width}">{
  for $x in $new-list//*:item
  let $pos := count($new-list//*:item) - count($x/following-sibling::*:item)
  let $y := ($pos * 20) + 30
  let $line-end := (number($x/@count) * 10) + 80
  return  <g class="bar">
            <text x="{20}" y="{$y}" fill="black">{$x/@id/string()}</text>
            <line x1="80" y1="{$y}" x2="{$line-end}" y2="{$y}" style="stroke:rgb(255,0,0);stroke-width:20"/>
          </g>
}</svg>

return $svg