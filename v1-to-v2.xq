declare function local:get-credit-roles($contrib as node()) as node()*{
  let $con-ref := $contrib/*:xref[matches(@rid,'^con\d+$')]/@rid
  let $con := $contrib/ancestor::*:article//*:fn[@id=$con-ref]
  return for $x in analyze-string($con,'Conceptuali[zs]ation|Data curation|Formal analysis|Funding acquisition|Investigation|Methodology|Project administration|Resources|Software|Supervision|Validation|Visualization|Writing\s?[—––\-]\s?original draft|Writing\s?[—––\-]\s?review (&amp;|and) editing')/*
                 return 
                 if ($x/local-name()="match") then 
                   if (contains($x,'review')) then (
                     <role vocab="credit" vocab-identifier="http://credit.niso.org/" 
                          vocab-term="Writing – review &amp; editing"
                          vocab-term-identifier="http://credit.niso.org/contributor-roles/writing-review-editing/">{$x/text()}</role>)
                   else if (contains($x,'original')) then (
                     <role vocab="credit" vocab-identifier="http://credit.niso.org/" 
                          vocab-term="Writing – original draft"
                          vocab-term-identifier="http://credit.niso.org/contributor-roles/writing-original-draft/">{$x/text()}</role>)
                   else (
                    <role vocab="credit" vocab-identifier="http://credit.niso.org/" 
                          vocab-term="{$x/text()}"
                          vocab-term-identifier="{('http://credit.niso.org/contributor-roles/'||
                        replace(lower-case($x),'\s','-')||'/')}">{$x/text()}</role>)
                        
                 else if (replace($x,'[\s,]','')="") then ()
                 else <role>{replace($x/text(),'^\s?,?\s','')}</role>
};

let $folder := '/Users/fredatherden/Desktop/elife-66031-vor-r3/'
for $file in file:list($folder)[ends-with(.,'.xml')]
let $xml := doc($folder||$file)

let $new-xml := copy $copy := $xml
               modify(
                insert node attribute specific-use {"version-of-record"} into $copy//*:article,
                  
                replace value of node $copy//*:article/@dtd-version with "1.2",
                 
                replace value of node $copy//*:article-categories/*:subj-group[@subj-group-type="display-channel"]/@subj-group-type with "heading",
                  
                for $x in $copy//*:article-categories
                let $msa-count := count($x/*:subj-group[@subj-group-type="heading"])
                return if ($msa-count=0) then ()
                else if ($msa-count=1) then replace value of node $x/*:subj-group[@subj-group-type="heading"]/@subj-group-type with "major-subject"
                else (
                  for $y in $x/*:subj-group[@subj-group-type="heading"] return delete node $y,
                  insert node <subj-group subj-group-type="major-subject">{$x/*:subj-group[@subj-group-type="heading"]/*:subject}</subj-group> as last into $x
                ),
                  
                for $x in $copy//*:aff/*:addr-line
                return replace node $x with <city>{$x/data()}</city>,
                  
                insert node attribute content-type {"authors"} into $copy//*:article-meta/*:contrib-group[1],
                  
                replace value of node $copy//*:article-meta/*:contrib-group[@content-type="section"]/@content-type with "peer-review",
                  
                delete node $copy//*:article-meta/*:pub-date[@pub-type="collection"],
                
                delete node $copy//*:article-meta/*:kwd-group[@kwd-group-type="research-organism"]/*:title,
                
                for $x in $copy//*:article-meta/*:pub-date[@date-type="publication"]
                return (
                  replace value of node $x/@date-type with "pub",
                  if ($x/*:year and $x/*:month and $x/*:day) then 
                      insert node attribute iso-8601-date {($x/*:year[1]||'-'||$x/*:month[1]||'-'||$x/*:day[1])} as last into $x
                ),
                
                replace value of node $copy//*:article-meta/*:kwd-group[@kwd-group-type="author-keywords"]/@kwd-group-type with "author-generated",
                  
              for $x in $copy//*:article-meta 
              return (
                if ($x/ancestor::*:article/*:back//*:fn-group[@content-type="competing-interest"]) then (
                  delete node $x/ancestor::*:article/*:back//*:fn-group[@content-type="competing-interest"],
                  if ($x/*:author-notes) then (
                    for $y in $x/ancestor::*:article/*:back//*:fn-group[@content-type="competing-interest"]/*:fn
                    return insert node $y into $x/*:author-notes
                  )
                  else insert node <author-notes>{
                    $x/ancestor::*:article/*:back//*:fn-group[@content-type="competing-interest"]/*:fn
                  }</author-notes> after $x/contrib-group[last()]
                ),
                if ($x/*:custom-meta-group/*:custom-meta[*:meta-name="Author impact statement"]) then
                    (
                      delete node $x/*:custom-meta-group/*:custom-meta[*:meta-name="Author impact statement"],
                      insert node <custom-meta specific-use="meta-only">
                                    <meta-name>elife-xml-version</meta-name>
                                    <meta-value>2.0</meta-value>
                                  </custom-meta>
                                  as last into $x/*:custom-meta-group,
                      insert node <custom-meta specific-use="meta-only">
                                    <meta-name>pdf-template</meta-name>
                                    <meta-value>6</meta-value>
                                  </custom-meta>
                                  as last into $x/*:custom-meta-group,
                      insert node <abstract abstract-type="toc"><p>{
                            $x/*:custom-meta-group/*:custom-meta/*:meta-value/(*|text())
                          }</p></abstract> before $x/*:abstract[1]
                    ) 
              ),
              
                for $x in $copy//*:back/*:sec[@sec-type="additional-information"]
                return 
                  if ($x/*:sec[@sec-type="ethics-statement"]) then (
                   for $y in $x/(*:sec[@sec-type!="ethics-statement"]|*:fn-group) return delete node $y 
                  )
                  else delete node $x,
                  
               for $x in $copy//*:article-meta//*:funding-source//*:institution-id 
               return replace node $x with 
                      <institution-id institution-id-type="doi" vocab="open-funder-registry" vocab-identifier="10.13039/open-funder-registry">{
                        substring-after($x,'doi.org/')
                      }</institution-id>,
                
                for $x in $copy//*:named-content[starts-with(@content-type,'author-callout')]
                let $style := $x/@content-type
                let $new-style := if ($style="author-callout-style-a1") then "color: #366BFB"
                                  else if ($style="author-callout-style-a2") then "color: #9C27B0"
                                  else if ($style="author-callout-style-a3") then "color: #D50000"
                                  else "broken"
                return replace node $x with <styled-content style="{$new-style}">{$x/(*|text())}</styled-content>,
                
                for $x in $copy//(*:td[@style]|*:th[@style])
                let $prec-text := "author-callout-style-b"
                let $style := $x/@style
                let $new-style := if ($style=($prec-text||"1")) then "background-color: #90caf9"
                                  else if ($style=($prec-text||"2")) then "background-color: #C5E1A5"
                                  else if ($style=($prec-text||"3")) then "background-color: #FFB74D"
                                  else if ($style=($prec-text||"4")) then "background-color: #FFF176"
                                  else if ($style=($prec-text||"5")) then "background-color: #9E86C9"
                                  else if ($style=($prec-text||"6")) then "background-color: #E57373"
                                  else if ($style=($prec-text||"7")) then "background-color: #F48FB1"
                                  else if ($style=($prec-text||"8")) then "background-color: #E6E6E6"
                                  else "broken"
                return replace value of node $x/@style with $new-style,
                
                for $x in $copy//*:sub-article
                let $new-type := if ($x/@article-type="decision-letter") then "referee-report" 
                                 else if ($x/@article-type="reply") then "author-comment"
                                 else $x/@article-type
                return replace value of node $x/@article-type with $new-type,
                
                for $x in $copy//*:sub-article//*:contrib
                return 
                if ($x/@contrib-type) then replace value of node $x/@contrib-type with "author"
                else insert node attribute contrib-type {"author"} into $x,
                
                for $x in $copy//*:sub-article[@article-type="decision-letter"]/*:front-stub/*:contrib-group[1]//*:role
                return insert node attribute specific-use {"editor"} into $x,
                
                for $x in $copy//*:sub-article[@article-type="decision-letter"]/*:front-stub/*:contrib-group[2]//*:role
                return insert node attribute specific-use {"referee"} into $x,
                  
                for $x in $copy//*:article-meta//*:contrib[@contrib-type="author" and not(ancestor::*:collab)]
                let $credits := local:get-credit-roles($x)
                return (
                    delete node $x/@id,
                    for $y in $x/*:xref[@ref-type=("fn","other")]
                      return if (contains($y/@rid,'fund')) then delete node $y
                             else replace value of node $y/@ref-type with "author-notes",
                    delete node $x/*:xref[matches(@rid,'^con\d+$')],
                    for $y in $credits return insert node $y after $x/*:name[1]
                )
               )
                return $copy
return file:write(('/Users/fredatherden/Desktop/'||$file),$new-xml, 
                  map{
                    'indent':'no',
                   'omit-xml-declaration':'no',
                   'doctype-system':'JATS-archivearticle1-mathml3.dtd',
                   'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD with MathML3 v1.2 20190208//EN'
                  }
)