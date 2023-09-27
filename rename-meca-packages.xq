let $meca-folder := '/Users/fredatherden/Desktop/mecas/'
let $meca-lookup := tokenize(file:read-text('/Users/fredatherden/Documents/GitHub/enhanced-preprints-data/meca-lookup.txt'),'\n')
let $ids := tokenize(file:read-text('/Users/fredatherden/Documents/GitHub/enhanced-preprints-data/manuscripts.txt'),'\n')

let $meca-paths := for $file in file:list($meca-folder)[.!='.DS_Store']
              let $path := $meca-folder||$file
              return 
                if (file:is-dir($path)) then (
                  for $f in file:list($path)[.!='.DS_Store']
                  return $path||$f
                )
                else $path

for $path in $meca-paths
let $meca := tokenize($path,'/')[last()]
let $folder := substring-before($path,$meca)

let $preprint-doi := if ($meca-lookup[contains(.,$meca)]) then substring-before($meca-lookup[contains(.,$meca)],'=')
return 
  if ($preprint-doi) then 
    if (matches($preprint-doi,'\[\d\]$')) then (
      let $version := substring-before(substring-after($preprint-doi,'['),']')
      let $preprint-doi := substring-before($preprint-doi,'[')
      let $id := if ($ids[contains(.,$preprint-doi)]) then substring-before($ids[contains(.,$preprint-doi)],':')
      let $filename := $id||'-v'||$version||'-meca.zip'
      let $filepath := $meca-folder||$filename
      return file:copy($path,$filepath)
    )
    else (
      let $id := if ($ids[contains(.,$preprint-doi)]) then substring-before($ids[contains(.,$preprint-doi)],':')
      let $filename := $id||'-v1-meca.zip'
      let $filepath := $meca-folder||$filename
      return file:copy($path,$filepath)
    )
  else ()