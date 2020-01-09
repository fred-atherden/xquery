let $xml := doc('/Users/fredatherden/Documents/GitHub/reference-manuscripts/manuscripts/00002/elife-00002.xml')

for $x in $xml//*:ref
let $year := $x/descendant::*:year[1]
let $cite := 
 if ((count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/name)
    then concat($year/ancestor::element-citation/person-group[1]/name/surname,', ',$year)

else if ((count($year/ancestor::element-citation/person-group[1]/*) = 1) and $year/ancestor::element-citation/person-group[1]/collab)
    then concat($year/ancestor::element-citation/person-group[1]/collab,', ',$year)

else if ((count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab')
    then concat($year/ancestor::element-citation/person-group[1]/collab,' and ',$year/ancestor::element-citation/person-group[1]/name/surname,', ',$year)

else if ((count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 1) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name')
    then concat($year/ancestor::element-citation/person-group[1]/name/surname,' and ',$year/ancestor::element-citation/person-group[1]/collab,', ',$year)

else if ((count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/name) = 2))
    then concat($year/ancestor::element-citation/person-group[1]/name[1]/surname,' and ',$year/ancestor::element-citation/person-group[1]/name[2]/surname,', ',$year)

else if ((count($year/ancestor::element-citation/person-group[1]/*) = 2) and (count($year/ancestor::element-citation/person-group[1]/collab) = 2))
    then concat($year/ancestor::element-citation/person-group[1]/collab[1],' and ',$year/ancestor::element-citation/person-group[1]/collab[2],', ',$year)

else if ((count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'collab')
    then concat($year/ancestor::element-citation/person-group[1]/collab[1], ' et al., ',$year)

else if ((count($year/ancestor::element-citation/person-group[1]/*) ge 2) and $year/ancestor::element-citation/person-group[1]/*[1]/local-name() = 'name')
    then concat($year/ancestor::element-citation/person-group[1]/name[1]/surname, ' et al., ',$year)
    
    else ()
    
    return <xref ref-type="bibr" rid="{$x/@id}">{$cite}</xref>