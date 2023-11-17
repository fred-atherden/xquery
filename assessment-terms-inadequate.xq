declare variable $folder := '/Users/fredatherden/Desktop/assessment-terms/';

for $file in file:list($folder)[ends-with(.,'.xml')]
let $xml := doc($folder||$file)
where $xml//*:terms/@version="1" and  $xml//*:term[@type="strength" and .='inadequate']
return 'https://elifesciences.org/reviewed-preprints/'||$xml//*:terms/@id||'v'||$xml//*:terms/@version