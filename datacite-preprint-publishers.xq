declare variable $query := 'https://api.datacite.org/clients?resource-type-id:Preprint&amp;page[size]=1000&amp;page[cursor]=1';
declare variable $list := <list/>;
declare function local:get-datacite-preprint-clients($query as xs:string, $list as node()) {
  let $res := json:parse(fetch:text($query))/*:json
  let $new-list := copy $copy := $list
                   modify(
                     for $x in $res/data/*/attributes/name
                     return insert node $x as last into $copy
                   )
                   return $copy
  
  return 
  if ($res/links/next)
      then local:get-datacite-preprint-clients($res/links/next,$new-list)
  else $new-list
};

local:get-datacite-preprint-clients($query,$list)