count(for $x in collection('articles')//*:element-citation
return 
if ($x//pub-id[@pub-id-type="doi"]) then $x
else ()) div count(collection('articles')//*:element-citation) * 100