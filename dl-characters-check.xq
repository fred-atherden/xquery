let $dl := doc('/Users/fredatherden/Desktop/dl.xml')
let $regex := '[^\sa-zA-Z0-9\(\)\[\]#=≡:,\./äé&amp;&apos;&quot;ü\?\+±\*;%!\p{IsGreek}‘’“”`~…–\^̂_∼<>\|∫∆]'
return distinct-values(analyze-string($dl,$regex)//*:match)