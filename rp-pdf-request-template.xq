let $articles := <list>
<article id="88900" version="2"/>
<article id="90713" version="1"/>
<article id="84355" version="2"/>
</list>
return ('@Ryan Dix-Peek Please could we have PDFs for the following?',
  for $x in $articles//*:article
  return 'https://elifesciences.org/reviewed-preprints/'||$x/@id||'v'||$x/@version
)