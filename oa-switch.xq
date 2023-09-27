let $date-filter := '2021-11-10'
let $folder := '/Users/fredatherden/Desktop/switch/'

for $file in file:list($folder)[ends-with(.,'.xml')]
let $xml := doc($folder||$file)
let $accep := $xml//*:article-meta//*:date[@date-type="accepted"]/@iso-8601-date/string()
order by $accep descending
where $accep gt $date-filter
return '10.7554/eLife.'||substring-before(substring-after($file,'elife-'),'.xml')