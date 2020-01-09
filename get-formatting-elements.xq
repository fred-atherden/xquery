let $formatting := ('bold','fixed-case','italic','monospace','overline','overline-start','overline-end','roman','sans-serif','sc','strike','underline','underline-start','underline-end','ruby','sub','sup')

return distinct-values(
  for $x in collection('f1000')//*
  let $name := $x/name()
  return 
  if ($name = $formatting) then $name
  else ()
)