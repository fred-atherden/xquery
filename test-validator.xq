declare namespace e = 'http://elifesciences.org/modules/validate';
import module namespace session = "http://basex.org/modules/session";
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace schematron = "http://github.com/Schematron/schematron-basex";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";


declare function e:svrl2json($svrl){
  
  let $errors :=
      concat(
         '"errors": [',
         string-join(
         for $error in $svrl//*[@role="error"]
         return concat(
                '{',
                ('"path": "'||$error/@location/string()||'",'),
                ('"type": "'||$error/@role/string()||'",'),
                ('"message": "'||e:get-message($error)||'"'),
                '}'
              )
          ,','),
        ']'
      )
let $warnings := 
     concat(
         '"warnings": [',
         string-join(
         for $warn in $svrl//*[@role=('info','warning','warn')]
         return concat(
                '{',
                ('"path": "'||$warn/@location/string()||'",'),
                ('"type": "'||$warn/@role/string()||'",'),
                ('"message": "'||e:get-message($warn)||'"'),
                '}'
              )
          ,','),
        ']'
      )
      
let $json :=  
    concat(
      '{
        "results": {',
      $errors,
      ',',
      $warnings,
      '} }'
    )
return $json
};

declare function e:json-escape($string){
  normalize-space(replace(replace($string,'\\','\\\\'),'"','\\"'))
};

declare function e:get-message($node){
  if ($node[@see]) then (e:json-escape(data($node))||' <a href="\'||$node/@see||'\">'||$node/@see||'</a>')
  else e:json-escape(data($node))
};

declare function e:update-refs($schema,$path2schema){
  let $filename := tokenize($path2schema,'/')[last()]
  let $folder := substring-before($path2schema,$filename)
  let $external-variables := distinct-values(
                      for $x in $schema//*[@test[contains(.,'document(')]]
                      let $variable := substring-before(substring-after($x/@test,'document($'),')')
                      return $variable
                    )
  return
  copy $copy := $schema
                modify(
                  for $x in $copy//*:let[@name=$external-variables]
                  return replace value of node $x/@value with concat("'",$folder,replace($x/@value/string(),"'",''),"'")
                )
                return $copy
  
};

declare function e:validate($xml,$schema){
  
  try {schematron:validate($xml, $schema)}
  (: Return psuedo-svrl to output error message for fatal xslt errors :)
  catch * { <schematron-output><successful-report id="validator-broken" location="unknown" role="error"><text>{'Error [' || $err:code || ']: ' || $err:description}</text></successful-report></schematron-output>}
};


  let $xml := doc('/Users/fredatherden/Downloads/194192.xml')
  let $schema := doc('/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/src/pre-JATS-schematron.sch')
  let $sch := schematron:compile(e:update-refs($schema,$schema/base-uri()))
  let $svrl :=  e:validate($xml, $sch)

return e:svrl2json($svrl)