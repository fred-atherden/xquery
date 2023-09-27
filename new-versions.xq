let $poa-list := <list>{
              for $x in collection('articles')//*:article[not(*:body)]
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}">{$b}</item>
             }</list>
             
let $vor-list := <list>{
              for $x in collection('articles')//*:article[*:body]
              let $b := $x/base-uri()
              let $id := substring-before(substring-after($b,'/articles/elife-'),'-v')
              order by $b
              return <item id="{$id}">{$b}</item>
             }</list>

let $poas := ('PoA V2s',
             for $x in distinct-values($poa-list//*:item/@id)
             let $matches := $poa-list//*:item[@id=$x]
             where count($matches) gt 1
             return $matches[position() gt 1]/text())

let $vors := ('VoR V2s',
             for $x in distinct-values($vor-list//*:item/@id)
             let $matches := $vor-list//*:item[@id=$x]
             where count($matches) gt 1
             return $matches[position() gt 1]/text())

return ($poas,$vors)