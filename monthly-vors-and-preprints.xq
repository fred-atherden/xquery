let $start-date := replace(string(current-date() - xs:dayTimeDuration("P28D")),'Z$','')
let $end-date := replace(string(current-date() - xs:dayTimeDuration("P21D")),'Z$','')
let $text := fetch:text('https://api.crossref.org/v1.0/works?filter=relation.type:has-preprint,prefix:10.7554,from-deposit-date:'||$start-date||',until-deposit-date:'||$end-date||'&amp;select=DOI,relation,deposited&amp;rows=1000')

for $x in json:parse($text)//*:items/_
let $deposited := string-join($x/*:deposited/date-parts/_/_,'-')
let $date := if (some $x in tokenize($deposited,'-') satisfies string-length($x)=1)
                 then xs:date(string-join(for $x in tokenize($deposited,'-') 
                                          return if (string-length($x)=1) then '0'||$x
                                          else $x
                              ,'-'))
             else xs:date($deposited)
order by $date descending
return 'deposited:'||$deposited||' '||$x/DOI||' preprint:'||$x/relation/has-preprint/_/id