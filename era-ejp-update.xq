let $update := <update>
  <article id="72865" status="trying-myself"/>
  <article id="70056" status="invited"/>
  <article id="74161" status="contacted"/>
  <article id="75228" status="tried-but-failed"/>
  <article id="74242" status="ignored"/>
  <article id="78525" status="ignored"/>
  <article id="74777" status="ignored"/>
  <article id="67790" status="ignored"/>
  <article id="76989" status="ignored"/>
  <article id="74901" status="ignored"/>
  <article id="76544" status="ignored"/>
  <article id="75055" status="ignored"/>
  <article id="78168" status="ignored"/>
  <article id="75253" status="ignored"/>
  <article id="73699" status="ignored"/>
  <article id="78129" status="ignored"/>
  <article id="80167" status="ignored"/>
  <article id="58433" status="ignored"/>
  <article id="76391" status="ignored"/>
  <article id="76381" status="ignored"/>
  <article id="74447" status="ignored"/>
</update>

let $era := collection('era')//*:articles

for $x in $update//*:article
where not($era//*:article/@id = $x/@id)
return insert node $x as last into $era