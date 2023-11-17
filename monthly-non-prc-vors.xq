declare variable $month := '2023-09';
declare variable $article-types := ('research-article','research-advance','tools-resources','short-report');

declare function local:get-latest-article-list($db-name as xs:string*) as element() {
let $list1 := <list>{
    for $x in collection($db-name)//*:article
    let $type := lower-case($x//*:article-meta//*:subj-group[@subj-group-type="display-channel"]/*:subject[1])
    let $is-prc := if ($x//*:article-meta//*:custom-meta[*:meta-name='publishing-route']/meta-value='prc') then 'yes'
                   else 'no'
    let $b := $x/base-uri()
    let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
    order by $b
    where $type!='feature article'
    return <item id="{$id}" doi="{'10.7554/eLife.'||$id}" is-prc="{$is-prc}">{$b}</item>
    }</list>
let $list2 :=  <list>{
    for $x in $list1/*:item
    let $id := $x/@id/string()
    return
    if ($x/following-sibling::*:item[1]/@id/string() = $id) then ()
    else $x
    }</list>
return $list2
};


let $latest-articles := local:get-latest-article-list('articles')

let $json := 
for $x in (1,2,3,4,5)
let $text := fetch:text('https://observer.elifesciences.org/report/exeter-new-and-updated-vor-articles.json?per-page=100&amp;page='||string($x))
let $fixed-text := '['||replace(string-join(tokenize($text,'\n'),','),',$','')||']'
return json:parse($fixed-text)

let $list := <list>{
    for $x in $json//*:_
    where $x/*:article-type=$article-types and starts-with($x/*:first-vor-published-date,$month)
    return <item doi="{$x/*:doi}" pub-date="{$x/*:first-vor-published-date}"/>
    }</list>

for $x in $list//*:item
where not($latest-articles//*:item[@doi=$x/@doi and @is-prc='yes'])
let $id := substring-after($x/@doi,'ife.')
return $id