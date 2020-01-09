for $x in collection('articles')//*:article/*:sub-article[1]//*:p
let $no := substring-before(substring-after($x/base-uri(),'/articles/elife-'),'-v')
return
if (matches($x,'^[Aa]cceptance summary[:]?$')) then 
  if (matches($x/following-sibling::*:p[2],'^Decision letter after peer review[:]?$')) 
      then (
            ($no||' - '||('https://elifesciences.org/articles/'||$no||'#'||$x/ancestor::*:sub-article/@id)),
            '&#xa;',
            $x/following-sibling::*:p[1]/data(),
            '&#xa;',
            '  ----  ',
            '&#xa;'
           )
  else if (matches($x/following-sibling::*:p[3],'^Decision letter after peer review[:]?$'))
      then (
            ($no||' - '||('https://elifesciences.org/articles/'||$no||'#'||$x/ancestor::*:sub-article/@id)),
            '&#xa;',
            $x/following-sibling::*:p[1]/data(),
            $x/following-sibling::*:p[2]/data(),
            '&#xa;',
            '  ----  ',
            '&#xa;'
           )
  else if (matches($x/following-sibling::*:p[4],'^Decision letter after peer review[:]?$'))
     then (
            ($no||' - '||('https://elifesciences.org/articles/'||$no||'#'||$x/ancestor::*:sub-article/@id)),
            '&#xa;',
            $x/following-sibling::*:p[1]/data(),
            $x/following-sibling::*:p[2]/data(),
            $x/following-sibling::*:p[3]/data(),
            '&#xa;',
            '  ----  ',
            '&#xa;'
           )
    else if (matches($x/following-sibling::*:p[5],'^Decision letter after peer review[:]?$'))
     then (
            ($no||' - '||('https://elifesciences.org/articles/'||$no||'#'||$x/ancestor::*:sub-article/@id)),
            '&#xa;',
            $x/following-sibling::*:p[1]/data(),
            $x/following-sibling::*:p[2]/data(),
            $x/following-sibling::*:p[3]/data(),
            $x/following-sibling::*:p[4]/data(),
            '&#xa;',
            '  ----  ',
            '&#xa;'
           )

    else if (matches($x/following-sibling::*:p[6],'^Decision letter after peer review[:]?$'))
     then (
            ($no||' - '||('https://elifesciences.org/articles/'||$no||'#'||$x/ancestor::*:sub-article/@id)),
            '&#xa;',
            $x/following-sibling::*:p[1]/data(),
            $x/following-sibling::*:p[2]/data(),
            $x/following-sibling::*:p[3]/data(),
            $x/following-sibling::*:p[4]/data(),
            $x/following-sibling::*:p[5]/data(),
            '&#xa;',
            '  ----  ',
            '&#xa;'
           )
     else if (matches($x/following-sibling::*:p[7],'^Decision letter after peer review[:]?$'))
     then (
            ($no||' - '||('https://elifesciences.org/articles/'||$no||'#'||$x/ancestor::*:sub-article/@id)),
            '&#xa;',
            $x/following-sibling::*:p[1]/data(),
            $x/following-sibling::*:p[2]/data(),
            $x/following-sibling::*:p[3]/data(),
            $x/following-sibling::*:p[4]/data(),
            $x/following-sibling::*:p[5]/data(),
            $x/following-sibling::*:p[6]/data(),
            '&#xa;',
            '  ----  ',
            '&#xa;'
           )
   else if (count($x/following-sibling::*:p)lt 3) 
       then (
            ($no||' - '||('https://elifesciences.org/articles/'||$no||'#'||$x/ancestor::*:sub-article/@id)),
            '&#xa;',
            for $y in $x/following-sibling::*:p
            return $y/data(),
            '&#xa;',
            '  ----  ',
            '&#xa;'
           )  
   else (($no||' - '||'ERROR'))
else ()
  