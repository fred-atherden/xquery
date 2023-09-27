(: RUN write-assessment-terms-to-folder.xq FIRST :)
declare variable $folder := '/Users/fredatherden/Desktop/assessment-terms/';

let $csv := <csv>
 <record>
  <entry>ID</entry>
  <entry>Version 1 significance terms</entry>
  <entry>Version 1 strength terms</entry>
  <entry>Version 1 assessment</entry>
  <entry>Version 2 significance terms</entry>
  <entry>Version 2 strength terms</entry>
  <entry>Version 2 assessment</entry>
 </record>{
 for $file in file:list($folder)[ends-with(.,'.xml') and contains(.,'v2')]
  let $id := substring-before($file,'v')
  let $v2 := doc($folder||$file)
  let $v1 := doc($folder||$id||'v1.xml')
  return <record>
          <entry>{$id}</entry>
          <entry>{string-join(distinct-values($v1//*:term[@type="significance"]),'; ')}</entry>
          <entry>{string-join(distinct-values($v1//*:term[@type="strength"]),'; ')}</entry>
          <entry>{$v1//*:assessment/data()}</entry>
          <entry>{string-join(distinct-values($v2//*:term[@type="significance"]),'; ')}</entry>
          <entry>{string-join(distinct-values($v2//*:term[@type="strength"]),'; ')}</entry>
          <entry>{$v2//*:assessment/data()}</entry>
         </record>
}</csv>

return file:write('/Users/fredatherden/Desktop/assessments.csv',$csv, map{'method':'csv','encoding':'UTF-8'})