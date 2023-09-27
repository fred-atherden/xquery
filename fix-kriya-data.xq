(: get list of exports in bucket aws s3 ls s3://elife-accepted-submission-cleaning/ > list.txt
   and edit so that it looks like <item><date>2021-04-12</date><zip>16-04-2020-RA-eLife-57964.zip</zip></item>
   save as list.xml on desktop :)

let $report := csv:parse(file:read-text('/Users/fredatherden/Documents/kriya-data/feb-report.csv'))
let $list := doc('/Users/fredatherden/Desktop/list.xml')
let $csv := <csv>
  <record>
    <entry>Article</entry>
    <entry>Word Count</entry>
    <entry>Exclude Reference</entry>
    <entry>Days in production</entry>
    <entry>Current Stage</entry>
    <entry>Article Type</entry>
    <entry>Assignee</entry>
    <entry>Times at Support</entry>
    <entry>Days in Support</entry>
    <entry>Times at Hold</entry>
    <entry>Days in Hold</entry>
    <entry>Accepted Date</entry>
    <entry>Exported Date</entry>
    <entry>Pre-editing</entry>
    <entry>Copyediting</entry>
    <entry>Typesetter Check</entry>
    <entry>Waiting for Assets</entry>
    <entry>Publisher Check</entry>
    <entry>Author Review</entry>
    <entry>Feature Review</entry>
    <entry>Typesetter Review</entry>
    <entry>Publisher Review</entry>
    <entry>Ready for Publication</entry>
    <entry>Validation Check</entry>
    <entry>Final Deliverables</entry>
    <entry>Archive</entry>
    <entry>Author</entry>
    <entry>Rating</entry>
    <entry>Additional Comments</entry>
  </record>{
    for $x at $pos in $report//*:record
    where $pos gt 1
    let $id := $x/*:entry[1]
    let $export := $x/*:entry[13]
    let $real-export := $list//*:item[contains(*:zip,$id)]/*:date
    return if ($export = $real-export) then $x
    else <record>{
     $x/*:entry[1],
$x/*:entry[2],
$x/*:entry[3],
$x/*:entry[4],
$x/*:entry[5],
$x/*:entry[6],
$x/*:entry[7],
$x/*:entry[8],
$x/*:entry[9],
$x/*:entry[10],
$x/*:entry[11],
$x/*:entry[12],
<entry>{$real-export/text()}</entry>,
$x/*:entry[14],
$x/*:entry[15],
$x/*:entry[16],
$x/*:entry[17],
$x/*:entry[18],
$x/*:entry[19],
$x/*:entry[20],
$x/*:entry[21],
$x/*:entry[22],
$x/*:entry[23],
$x/*:entry[24],
$x/*:entry[25],
$x/*:entry[26],
$x/*:entry[27],
$x/*:entry[28],
$x/*:entry[29] 
    }
    </record>
  }</csv>

return file:write('/Users/fredatherden/Desktop/feb-report-fixed.csv',$csv, map{'method':'csv'})
