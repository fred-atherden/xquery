let $report := doc('/Users/fredatherden/Desktop/test-folder/report.xml')

let $values := for $x in $report//*:item
return count($x/*[@role=('error','warning')])

let $list := for $y in $values
order by number($y)
return $y

let $count := count($list)

let $median-number :=  
if (($count mod 2)=1) then (($count div 2)+0.5)
else (
      ($count div 2),
      (($count div 2)+1)
    )

let $median := 
if (count($median-number)=1) then (
        for $x in $list[position()=$median-number]
        return $x
        )
else (sum(for $x in $list[position()=$median-number]
        return $x) div 2)

return $median