let $pre-report := doc('/Users/fredatherden/Desktop/pre-edit/pre-report.xml')
let $pub-report := doc('/Users/fredatherden/Desktop/pub-check/pub-report.xml')

let $ignore-message-ids := ('test-r-article-a-reply','code-fork-info','supplementary-material-test-2','pre-test-r-article-d-letter','pre-pub-date-test-1','pre-pub-date-test-2')

for $i in $pre-report//*:item
let $id := substring-before(substring-after($i/@name,'elife-'),'.xml')
let $error-count := count($i/*[@role="error"])
let $warn-count := count($i/*[@role="warning"])

return 
  if ($pub-report//*:item[@name=$i/@name]) then ( 
    let $pub := $pub-report//*:item[@name=$i/@name]
    let $pub-error-count := count($pub/*[@role="error"])
    let $pub-warn-count := count($pub/*[@role="warning"])
    let $diffs := string-join(
              for $m in $i/*[@role=('error','warning')]
              return if ($m/@id = $ignore-message-ids) then ()
                     else if ($pub/*[(@role=$m/@role) and @id = $m/@id]/@location = $m/@location) then ()
                     else if ($pub/*[(@role=$m/@role) and @id = $m/@id]/*:text = $m/*:text) then ()
                     else (normalize-space($m/data()))
            ,' --- ')
    return ($id||'	'||$i/@valid/string()||'	'||$error-count||'	'||$warn-count||'	'||$pub/@valid/string()||'	'||$pub-error-count||'	'||$pub-warn-count||'	'||$diffs)
     )
  else ($id||'	'||$i/@valid/string()||'	'||$error-count||'	'||$warn-count||'	NA	NA	NA	NA')