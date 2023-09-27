declare function local:number-from-month-string($string){
  switch ($string) 
   case "Jan" return "01"
   case "Feb" return "02"
   case "Mar" return "03"
   case "Apr" return "04"
   case "May" return "05"
   case "Jun" return "06"
   case "Jul" return "07"
   case "Aug" return "08"
   case "Sep" return "09"
   case "Oct" return "10"
   case "Nov" return "11"
   case "Dec" return "12"
   default return error(xs:QName("basex:error"),('Uh-oh! '||$string||' is not expected'))
};

let $year := '2018'
let $db := 'ejp-'||$year

let $regex := '^\d{2}[a-z][a-z] [A-Z][a-z]{2} \d{2}  \d{2}:\d{2}:\d{2}$'

for $x in (
          collection($db)//*:xml//*:version/*:history/*:stage/*:start-date[matches(.,$regex)],
          collection($db)//*:xml//*:version/*:emails/*:email/*:email-date[matches(.,$regex)]
      )
let $tokens := tokenize($x,'\s+')
let $new-date := (concat('20',$tokens[3])||
                  '-'||
                  local:number-from-month-string($tokens[2])||
                  '-'||
                  substring($tokens[1],1,2)||
                  'T'||
                  $tokens[last()])
return replace value of node $x with $new-date