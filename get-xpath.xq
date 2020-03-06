 distinct-values(
   for $x in collection('biorxiv')//*:ack
   let $xpath := concat('/',
                        string-join(for $a in $x/ancestor::*
                             order by $a/position()
                             return $a/name(),'/'),
                        '/ack')
   return if ($x/parent::*:back) then ()
   else ($xpath|| ' - ' || $x/base-uri())
)