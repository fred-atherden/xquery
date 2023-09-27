(: 
Run the following commands first:

cd desktop
aws s3 ls s3://elife-accepted-submission-cleaning/ > new-bucket.txt
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

declare function local:get-latest-article-list($db-name as xs:string*) as element() {
  let $list1 := <list>{
              for $x in collection($db-name)//*:article[*:body]
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              let $pub := $x//*:article-meta/*:pub-date[@publication-format="electronic"][1]
              let $pub-date := ($pub/*:year[1]||$pub/*:month[1]||$pub/*:day[1])
              order by $b
              return <item id="{$id}" base="{$b}" pub-date="{$pub-date}"/>
              }</list>
 
  let $list2 :=  <list>{
                  for $x in $list1/*:item
                  where $x/@pub-date gt '20210224'
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
                  }</list>

  return $list2
};

let $articles := local:get-latest-article-list('articles')
let $bucket := local:create-list(file:read-text('/Users/fredatherden/Desktop/new-bucket.txt'))


for $x in $articles//*:item
order by $x/@pub-date
let $id := $x/@id
return if (not($bucket//*:item/@id = $id)) then $x
(: The returned items are the ones missing from the 'new' bucket :)