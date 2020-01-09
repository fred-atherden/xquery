count(for $x in (collection('pmc1')//*:article[descendant::*:article-categories[*:subj-group/child::*:subject[2]]],
           collection('pmc2')//*:article[descendant::*:article-categories[*:subj-group/child::*:subject[2]]],
           collection('pmc3')//*:article[descendant::*:article-categories[*:subj-group/child::*:subject[2]]])
return $x)