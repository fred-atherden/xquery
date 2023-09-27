let $list := 
  for $x in collection('articles')//*:article[*:sub-article]
  let $text := string-join(for $y in $x/*:sub-article/*:body//* 
                         return $y/text(),' ')
  let $count := count(tokenize($text,'\s')[not(matches(.,'^[\p{P}]*$'))])
  order by $count
  return $count

let $total := count($list)

let $median-number :=  
  if (($total mod 2)=1) then (($total div 2)+0.5)
  else (
        ($total div 2),
        (($total div 2)+1)
      )

let $median := 
  if (count($median-number)=1) then (
        for $x in $list[position()=$median-number]
        return $x
        )
  else (sum(for $x in $list[position()=$median-number]
        return $x) div 2)

return $median