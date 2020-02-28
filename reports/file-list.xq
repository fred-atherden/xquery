for $x in file:list('/Users/fredatherden/Desktop/copyedit')
return
substring-after(substring-before($x,'-vor'),'-')
