let $articles := <list>
<article id="91705" version="1"/>
<article id="91498" version="1"/>
<article id="87518" version="2"/>
<article id="87611" version="2"/>
<article id="88087" version="2"/>
<article id="88637" version="2"/>
<article id="88659" version="2"/>
<article id="89467" version="2"/>
<article id="91011" version="1"/>
<article id="91861" version="2"/>
<article id="91976" version="1"/>
<article id="92201" version="2"/>
<article id="90214" version="2"/>
</list>
return ('@Ryan Dix-Peek Please could we have PDFs for the following?',
  for $x in $articles//*:article
  return 'https://elifesciences.org/reviewed-preprints/'||$x/@id||'v'||$x/@version
)