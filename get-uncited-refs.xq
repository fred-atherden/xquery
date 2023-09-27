let $xml := doc('/Users/fredatherden/Downloads/elife56186.xml')

for $ref in $xml//*:ref-list/*:ref
let $id := $ref/@id/string()
let $cite := 
      if ((count($ref/*:element-citation/*:person-group[@person-group-type="author"]/*)= 1) and $ref/*:element-citation/*:person-group[@person-group-type="author"]/*:name) 
         then ($ref/*:element-citation/*:person-group[@person-group-type="author"]/*/*:surname||
               ' '||
               $ref/*:element-citation/*:year)
      else  if ((count($ref/*:element-citation/*:person-group[@person-group-type="author"]/*)= 1) and $ref/*:element-citation/*:person-group[@person-group-type="author"]/*:collab) 
         then ($ref/*:element-citation/*:person-group[@person-group-type="author"]/*/*:collab||
               ' '||
               $ref/*:element-citation/*:year)
      else if ((count($ref/*:element-citation/*:person-group[@person-group-type="author"]/*)= 2) and count($ref/*:element-citation/*:person-group[@person-group-type="author"]/*:name)=2) 
         then ($ref/*:element-citation/*:person-group[@person-group-type="author"]/*[1]/*:surname[1]||
               ' and '||
               $ref/*:element-citation/*:person-group[@person-group-type="author"]/*[2]/*:surname[1]||
               ' '||
               $ref/*:element-citation/*:year)    
       else if ((count($ref/*:element-citation/*:person-group[@person-group-type="author"]/*)= 2) and count($ref/*:element-citation/*:person-group[@person-group-type="author"]/*:collab)=2) 
         then ($ref/*:element-citation/*:person-group[@person-group-type="author"]/*[1]||
               ' and '||
               $ref/*:element-citation/*:person-group[@person-group-type="author"]/*[2]||
               ' '||
               $ref/*:element-citation/*:year)
        else if ((count($ref/*:element-citation/*:person-group[@person-group-type="author"]/*) gt 2) and $ref/*:element-citation/*:person-group[@person-group-type="author"]/*[1]/name()='name') 
         then ($ref/*:element-citation/*:person-group[@person-group-type="author"]/*[1]/*:surname[1]||
               ' et al. '||
               $ref/*:element-citation/*:year)
         
return 
  if ($ref/ancestor::*:article//*:xref[@rid/string() = $id]) then ()
  else ($cite)