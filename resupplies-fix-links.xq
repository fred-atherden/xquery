declare namespace xlink="http://www.w3.org/1999/xlink";
declare variable $links := <list>
    <item id="77177" version="1" old="http://dx.doi:10.5061/dryad.1rn8pk0wb" new="http://doi.org/10.5061/dryad.1rn8pk0wb"/>
    <item id="77177" version="2" old="http://dx.doi:10.5061/dryad.1rn8pk0wb" new="http://doi.org/10.5061/dryad.1rn8pk0wb"/>
    <item id="16937" old="http://dx.doi:10.5061/dryad.c261c" new="http://doi.org/10.5061/dryad.c261c"/>
    <item id="19375" version="1" old="http://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS4057\x7f" new="http://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS4057"/>
    <item id="19375" version="2" old="http://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS4057\x7f" new="http://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS4057"/>
    <item id="32496" old="http://www.proteomecommons. org" new="http://www.proteomecommons.org"/>
    <item id="43598" old="https://dx.doi:10.5061/dryad.hp60p89" new="https://doi.org/10.5061/dryad.hp60p89"/>
    <item id="50160" old="https://www.ncbi.nlm. nih.gov/nucest/ FO263072" new="https://www.ncbi.nlm.nih.gov/nucest/FO263072"/>
    <item id="55320" old="https://www.ncbi.nlm. nih.gov/geo/query/acc. cgi?acc=GSE116246" new="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE116246"/>
    <item id="57189" old="https://portal.gdc.can- cer.gov/projects/TCGA- ESCA" new="https://portal.gdc.cancer.gov/projects/TCGA-ESCA"/>
    <item id="57799" old="http://gwips.ucc.ie, GWIPS-viz" new="https://gwips.ucc.ie/"/>
    <item id="59151" old="http://dx.doi:10.5061/dryad.0p2ngf1xg" new="http://doi.org/10.5061/dryad.0p2ngf1xg"/>
    <item id="62592" old="https://www-ncbi-nlm-nih-gov /geo/query/acc.cgi?acc=GSE48403" new="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE48403"/>
    <item id="71052" old="http://www.ncbi.nlm.nih. gov/geo/query/acc.cgi? acc=GSE153596" new="http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE153596"/>
    <item id="82241" old="https://academic.oup .com/nar/article/34/1 6/4642/3111902#su pplementary-data" new="https://academic.oup.com/nar/article/34/16/4642/3111902#supplementary-data"/>
    <item id="83153" old="http://www.ncbi.nlm.nih. gov/geo/query/acc.cgi? acc=GSE151196" new="http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE151196"/>
    <item id="57068" old="http://doi: 10.7554/eLife.30860" new="http://doi.org/10.7554/eLife.30860"/>
    <item id="60481" old="ftp://MSV000086611@massive.ucsd.edu Username for FTP access: MSV000086611" new="ftp://MSV000086611@massive.ucsd.edu"/>
    <item id="15192" old="http:// CRAN.R-project.org/package=lme4" new="http://CRAN.R-project.org/package=lme4"/>
    <item id="23203" old="https://www.R- project.org/" new="https://www.R-project.org/"/>
    <item id="32814" old="http://animaldiversity org." new="http://animaldiversity.org"/>
    <item id="24494" old="http://www. R-project. org" new="http://www.r-project.org/"/>
    <item id="33281" old="http://www.flycircuit.tw " new="http://www.flycircuit.tw"/>
    <item id="09419" old="http://globocan iarc fr/Pages/fact_sheets_cancer aspx 2013" new="https://gco.iarc.fr/"/>
    <item id="33660" old="http://www. cmu. edu/biolphys/deserno/pdf/membrane_theory. pdf" new="http://www.cmu.edu/biolphys/deserno/pdf/membrane_theory.pdf"/>
    <item id="34282" old="http://CRAN.R- project.org/package=lme4%3E" new="http://cran.r-project.org/package=lme4"/>
    <item id="36398" old="http://hannonlab. cshl. edu/fastx_toolkit 5." new="http://hannonlab.cshl.edu/fastx_toolkit/"/>
    <item id="22054" version="1" old="http://sourceforge net/projects/bbmap" new="http://sourceforge.net/projects/bbmap"/>
    <item id="22054" version="2" old="http://sourceforge net/projects/bbmap" new="http://sourceforge.net/projects/bbmap"/>
    <item id="35696" old="http://mypage. iu. edu/~ pdpolly/Software. html" new="http://mypage.iu.edu/~pdpolly/Software.html"/>
    <item id="60100" old="http://www:r-project.org" new="http://www.r-project.org/"/>
    <item id="36495" old="http://repeatmasker org" new="http://repeatmasker.org/"/>
</list>;

let $folder := '/Users/fredatherden/Desktop/resupplies/'
let $updated := ($folder||'updated/')

for $file in file:list($folder)[ends-with(.,'.zip')]
let $id := substring-before(substring-after($file,'elife-'),'-')
let $version := substring-before(substring-after(substring-after($file,($id||'-')),'-v'),'-')
let $zip := file:read-binary($folder||$file)
let $xml-entry := archive:entries($zip)[matches(.,'^elife-\d{5}-v\d\.xml$')]
let $link-item := if ($links//*:item[@id=$id and @version=$version]) then $links//*:item[@id=$id and @version=$version]
                  else $links//*:item[@id=$id]
let $broken-link := $link-item/@old
let $fixed-link := $link-item/@new
let $new-xml := copy $copy := fn:parse-xml(archive:extract-text($zip,$xml-entry))
                modify(
                  for $x in $copy//*:ext-link[@xlink:href=$broken-link]
                  return replace value of node $x/@xlink:href with $fixed-link
                )
                return $copy
let $temp-xml-loc := ($folder||'pdfs/'||$xml-entry/text())
return (
  file:write($temp-xml-loc,
             $new-xml,
             map {'indent':'no',
                  'omit-xml-declaration':'no',
                  'doctype-system':'JATS-archivearticle1-mathml3.dtd',
                  'doctype-public':'-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD with MathML3 v1.2 20190208//EN'}
                 ),
 let $updated-zip := archive:update($zip,$xml-entry,file:read-binary($temp-xml-loc))
 return (
   file:write-binary(($updated||$file),$updated-zip),
   file:delete($temp-xml-loc))
)