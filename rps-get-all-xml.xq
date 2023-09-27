let $dir := '/Users/fredatherden/Documents/GitHub/enhanced-preprints-data/data/'

for $folder in file:list($dir)[matches(.,'^\d{5,6}/$')]
  for $sub-folder in file:list($dir||$folder)[not(.='.DS_Store')]
    for $file in file:list($dir||$folder||$sub-folder)[ends-with(lower-case(.),'.xml')]
    let $xml := doc($dir||$folder||$sub-folder||$file)
    return $xml