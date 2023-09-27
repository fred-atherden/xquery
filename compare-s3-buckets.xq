(: 
Run the following commands first:

cd desktop
aws s3 ls s3://elife-accepted-submission-cleaning/ > new-bucket.txt
aws s3 ls s3://elife-ejp-raw-output/ > old-bucket.txt
:)

declare function local:create-list($text as xs:string) as element(){
  let $list := <list>{
    for $x in tokenize($text,'\n')
    let $item := <item>{
                  for $t at $p in tokenize($x,'\s+')
                  return switch ($p)
                    case 1 return element date {$t}
                    case 2 return element time {$t}
                    case 4 return element filename {$t}
                    default return ()
                  }</item>
    return $item
  }</list>
  
  return
  copy $copy := $list
  modify(
    for $x in $copy//*:item
    let $filename-ss := substring-after(lower-case($x/*:filename),'elife-')
    let $id := if (contains($filename-ss,'r')) then substring-before($filename-ss,'r')
           else substring-before($filename-ss,'.zip')
    return insert node attribute id {$id} as first into $x,
    
    for $x in $copy//*:item
    let $dateTime := $x/date||'T'||$x/time
    return insert node attribute dateTime {$dateTime} as last into $x,
    
    for $x in $copy//*:item/(*:date|*:time)
    return delete node $x
  )
  return $copy
};

let $new := local:create-list(file:read-text('/Users/fredatherden/Desktop/new-bucket.txt'))
let $old := local:create-list(file:read-text('/Users/fredatherden/Desktop/old-bucket.txt'))

for $x in $old//*:item
let $id := $x/@id
let $date-string := replace(substring-before($x/@dateTime,'T'),'-','')
where $date-string gt '20210224'
order by $x/@dateTime
return if (not($new//*:item/@id = $id)) then $x
(: The returned items are the ones missing from the 'new' bucket :)