declare variable $file := '/crossref/peer-review.xml';

declare updating function local:get-crossref-pr-dois($cursor) {
  let $peer-review := collection($file)//*:sub-dois
  
  let $query := ('https://api.crossref.org/prefixes/10.7554/works?filter=type:peer-review&amp;select=DOI&amp;rows=1000&amp;mailto=f.atherden@elifesciences.org&amp;cursor='||$cursor)
  let $request := http:send-request(<http:request method='get' href="{$query}" timeout='30'/>)
  
  return 
    if (not($request//*:total-results[@type="number"]) or number($request//*:total-results[@type="number"])=0) then (update:output('Finished. No more results at '||$cursor))
    else (
      let $next-cursor := web:encode-url($request//*:next-cursor)
      return
        (for $x in $request//*:items//_
         let $node := <item doi="{$x/*:DOI/text()}"/>
         return if ($peer-review//*:item[@doi = $node/@doi]) then ()
         else (insert node $node as last into $peer-review),
       
         local:get-crossref-pr-dois($next-cursor)
        )
    )
};

let $starting-cursor := '*'

return local:get-crossref-pr-dois($starting-cursor)