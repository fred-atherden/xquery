declare variable $folder := '/Users/fredatherden/Desktop/assessment-terms/';
declare variable $month := '2023-07';

for $file in file:list($folder)[ends-with(.,'.xml')]
let $xml := doc($folder||$file)
where $xml//*:terms[starts-with(@pub-date,$month)] and $xml//*:term[.='incomplete'] and $xml//*:term[@type="strength" and .!='incomplete']
return 'https://elifesciences.org/reviewed-preprints/'||$xml//*:terms/@id||'v'||$xml//*:terms/@version