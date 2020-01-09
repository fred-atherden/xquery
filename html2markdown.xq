declare function local:ul-list($ul){
  <placeholder>{
  for $x in $ul//*:li
  let $c := count($x/ancestor::*:ul)
  let $y := count($x/following-sibling::*:li)
  return
  if ($c = 1) then 
    if ($y=0) then  concat('- ',$x/data())
    else concat('- ',$x/data(),'&#xa;')
  else if ($c = 2) then concat('  - ',$x/data(),'&#xa;') 
  else if ($c = 3) then concat('    - ',$x/data(),'&#xa;') 
  else if ($c = 4) then concat('      - ',$x/data(),'&#xa;') 
  else concat('        - ',$x/data(),'
')  
  }</placeholder>
  
};

declare function local:ol-list($ol){
  <placeholder>{
    for $x in $ol//*:li
    let $pos := string(count($x/preceding-sibling::*:li) + 1)
    return 
    if ($x/following-sibling::*:li) then concat($pos,'. ',$x/data(),'&#xa;')
    else concat ($pos,'. ',$x/data())
  }</placeholder>
};

declare function local:edit-issue($issue){
  copy $copy := $issue
  modify(
    for $x in $copy//*:div[@class="comment"]
    let $c := count($x/preceding-sibling::*:div[@class="comment"])
    return 
    if ($c = 0) then ()
    else delete node $x,
    
    for $x in $copy//*:pre
    return replace node $x with $x/(*|text()),
    
    for $x in $copy//*:div[@class="body"]
    let $url := $x/ancestor::*:div[@class="container"]//*:header//*:span[@class="url"]//*:a/@href/string()
    return insert node <p>{concat('Taken from: ',$url)}</p> as last into $x,
    
    for $x in $copy//*:h3[parent::*:li]
    return 
    (delete node $x/parent::li,
     insert node $x before $x/ancestor::*:ul)
 )
  return copy $copy2 := $copy
  modify(
    for $x in $copy2/*:header
    return delete node $x,
    
    for $x in $copy2//*:div[@class="meta"]
    return delete node $x,
       
    for $x in $copy2//*:div[@class="body"]/*:ul
    let $pos := count($x/preceding-sibling::*:ul)
    return 
    if ($pos=0) then delete node $x
    else replace node $x with local:ul-list($x),
    
    for $x in $copy2//*:div[@class="body"]/*:ol
    return replace node $x with local:ol-list($x),
    
    for $x in $copy2//*:code
    return 
    if ($x/@class="lang-xml") then replace node $x with <placeholder>{concat('&#x60;&#x60;&#x60;xml
    ',$x/data(),'&#xa;&#x60;&#x60;&#x60;')}</placeholder>
    else replace node $x with concat('&#x60;',$x/data(),'&#x60;'),
    
    for $x in $copy2//*:a
    return replace node $x with <placeholder>{concat('[',$x/data(),']','(',$x/@href/string(),')')}</placeholder>,
    
    for $x in $copy2//*:h2
    return replace node $x with <placeholder>{concat('## ',$x/data())}</placeholder>,
    
    for $x in $copy2//*:h3
    return replace node $x with <placeholder>{concat('### ',$x/data())}</placeholder>,
    
    for $x in $copy2//*:h4
    return replace node $x with <placeholder>{concat('#### ',$x/data())}</placeholder>,
    
    for $x in $copy2//*:h5
    return replace node $x with <placeholder>{concat('##### ',$x/data())}</placeholder>
    
 )
 return copy $copy3 := $copy2
  modify(
    
    for $x in $copy3//*:div[@class="body"]/text()[1]
    return delete node $x,
    
    for $x in $copy3//(*:p|*:placeholder)
    return replace node $x with $x/text(),
    
    for $x in $copy3//*:div[@class="body"]/descendant::p[last()]/preceding-sibling::text()[1]
    return replace node $x with '&#xa;&#xa;'
    
  )
  return $copy3//*:div[@class="body"]/text()
};


for $x in collection('issue-test')/*:html//*:div[@class="container"]
let $name := $x/ancestor::body//*:h1/text()
let $filename := concat(substring-before(substring-after($x/base-uri(),'/issue-test/'),'html'),'md')
let $ticket := (concat($name,'&#xa;&#xa;'),
               local:edit-issue($x))
return 
file:write(concat('/Users/fredatherden/Desktop/issue-test/',$filename),$ticket,map{'method':'text','indent':'no'})

