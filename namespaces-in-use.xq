declare namespace functx = "http://www.functx.com";
declare function functx:namespaces-in-use
  ( $root as node()? )  as xs:anyURI* {

   distinct-values(
      $root/descendant-or-self::*/(.|@*)/namespace-uri(.))
 } ;

collection('ijm-xml')//*:article/functx:namespaces-in-use(.)