let $box := 'Kerwin J, Khan I, Reproducibility Project: Cancer Biology. 2020. Replication Study: A coding-independent function of gene and pseudogene mRNAs regulates tumour biology. eLife 9:e51019. doi: 10.7554/eLife.51019'

let $ref :=  'Kerwin J, Khan I, Reproducibility Project: Cancer Biology. 2020. Replication study: A coding-independent function of gene and pseudogene mRNAs regulates tumour biology. eLife 9:e51019. doi: 10.7554/eLife.51019'

for $t in tokenize($box,' ')
return if (contains($ref,$t)) then ()
else $t