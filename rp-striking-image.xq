(:Need to run write-assessment-terms-to-folder.xq first! :)

declare variable $folder := '/Users/fredatherden/Desktop/assessment-terms/';
let $current-day := format-date(current-date(),'[FNn]')
let $tues-date := switch ($current-day)
                    case 'Monday' return current-date() + xs:dayTimeDuration("P1D")
                    case 'Wednesday' return current-date() + xs:dayTimeDuration("P6D")
                    case 'Thursday' return current-date() + xs:dayTimeDuration("P5D")
                    case 'Friday' return current-date() + xs:dayTimeDuration("P4D")
                    default return current-date()


for $file in file:list($folder)[ends-with(.,'.xml')]
let $xml := doc($folder||$file)
let $pub-date := xs:date($xml/*:terms/@pub-date)
where (($tues-date - $pub-date) < xs:dayTimeDuration("P8D")) and $xml//*:term[@type="significance" and matches(.,'important|fundamental|landmark')] and $xml//*:term[@type="strength" and matches(.,'convincing|compelling|exceptional')]
return 'https://elifesciences.org/reviewed-preprints/'||$xml//*:terms/@id||'v'||$xml//*:terms/@version