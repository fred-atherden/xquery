let $list1 := <list>{
              for $x in collection('articles')//*:article
              let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return 
              if ($type = ('research article','short report','tools and resources','research advance')) then <item id="{$id}">{$b}</item>
              else ()
             }</list>
 
let $list2 :=  <list>{
                  for $x in $list1/*:item
                  let $id := $x/@id/string()
                  return
                  if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
                  else $x
}</list>

for $x in $list2//*:item
let $article := collection($x/text())//*:article
let $publisher := $article//*:journal-meta//*:publisher-name
let $journal := $article//*:journal-meta//*:journal-title
let $issn := $article//*:journal-meta//*:issn
let $doi := $article//*:article-meta//*:article-id[@pub-id-type="doi"]
let $sub := $article//*:article-meta/*:history/*:date[@date-type="received"]
let $sub-display := if ($sub[@iso-8601-date]) then $sub/@iso-8601-date
                    else ($sub/*:year[1]||'-'||$sub/*:month[1]||'-'||$sub/*:day[1])
let $acc := $article//*:article-meta/*:history/*:date[@date-type="accepted"]
let $acc-display := if ($acc[@iso-8601-date]) then $acc/@iso-8601-date
                    else ($acc/*:year[1]||'-'||$acc/*:month[1]||'-'||$acc/*:day[1])
let $pub := $article//*:article-meta/*:pub-date[@publication-format="electronic"][1]
let $pub-date := ($pub/*:year[1]||'-'||$pub/*:month[1]||'-'||$pub/*:day[1])
let $data := string-join(
                for $y in $article/*:back//*:sec[@sec-type="data-availability"]//*:element-citation
                return 
                if ($y/*:pub-id[@pub-id-type="doi"]) then ('https://doi.org/'||$y/*:pub-id[@pub-id-type="doi"])
                else if ($y/*:pub-id[@*:href]) then $y/*:pub-id/@*:href
                else if ($y/*:ext-link) then $y/*:ext-link/@*:href
                else ()
             ,'; ')
let $sub-article := string-join(for $z in $article/*:sub-article/*:front-stub/*:article-id[@pub-id-type="doi"]
                        return ('https://doi.org/'||$z),'; ')
return
($publisher||'	'||$journal||'	'||$issn||'	'||$doi||'	'||$sub-display||'	'||$acc-display||'	'||$pub-date||'			'||$data||'	'||$sub-article)
