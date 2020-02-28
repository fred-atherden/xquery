declare function local:time2seconds($time){
  let $items := ((number(tokenize($time,':')[position()=1]) * 3600),
                 (number(tokenize($time,':')[position()=2]) * 60),
                 number(tokenize($time,':')[position()=last()])
               )
  
  return sum($items)
};

let $csv := csv:parse(file:read-text('/Users/fredatherden/Desktop/fa-toggle.csv'), map { 'header': true() })

let $prod-tasks := ('Emails','Kriya - dashboard ','Pub Review','Features','New version','Continuum checks','Resupply','Affiliations','Pub check','PoA','Meetings','Work chat')

let $total := sum(for $x in $csv//*:Duration return local:time2seconds($x))

let $projects := distinct-values($csv//*:Project)

let $report-1 := <report>{
for $x in $projects
let $time := sum(for $y in $csv//*:record[*:Project = $x] return local:time2seconds($y/*:Duration))

return <task name="{$x}" time="{$time}"/>
}</report>

let $prod-time := (sum(for $p in $report-1//*:task
                      return if ($p/@name = $prod-tasks) then number($p/@time/string())
                      else ()) div 3600)

let $report-2 := <report total="{$total div 3600}">{
  (
    <task name="Production" hours="{$prod-time}"/>,
    for $x in $report-1//*:task
    return if ($x/@name = $prod-tasks) then ()
    else <task name="{$x/@name}" hours="{$x/@time div 3600}"/>)
}</report>

return $report-2