declare namespace functx = "http://www.functx.com";

declare function functx:day-of-week
 ($date as xs:anyAtomicType?) as xs:integer? {
 if (empty($date))
 then ()
 else
  xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7
};

declare function local:weekdays
 ($start as xs:anyAtomicType?, $end as xs:anyAtomicType?) as xs:integer? {
 if(empty($start) or empty($end))
 then()
 else
  if($start > $end)
  then -local:weekdays($end, $start)
  else
   let $dayOfWeekStart := functx:day-of-week($start)
   let $dayOfWeekEnd := functx:day-of-week($end)
   let $adjDayOfWeekStart := if($dayOfWeekStart = 0) then 7 else $dayOfWeekStart
   let $adjDayOfWeekEnd := if($dayOfWeekEnd = 0) then 7 else $dayOfWeekEnd
   return
    if($adjDayOfWeekStart <= $adjDayOfWeekEnd)
    then xs:integer((xs:integer(days-from-duration(xs:date($end) - xs:date($start)) div 7) * 5)
     + max(((min((($adjDayOfWeekEnd + 1), 6)) - $adjDayOfWeekStart), 0)))
    else xs:integer((xs:integer(days-from-duration(xs:date($end) - xs:date($start)) div 7) * 5)
     + min((($adjDayOfWeekEnd + 6) - min(($adjDayOfWeekStart, 6)), 5)))
};

let $start := '2022-02-16'
let $end := '2022-03-09'

return local:weekdays($start, $end)