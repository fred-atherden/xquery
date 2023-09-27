let $height := 500
let $width := 500

let $svg := <svg xmlns="http://www.w3.org/2000/svg" height="{$height}" width="{$width}">
  <polyline points="20,20 40,25 60,40 80,120 120,140 200,180 220,20" style="fill:none;stroke:black;stroke-width:3" />
  <text x="20" y="220" fill="black" transform="rotate(-90,20,220)">00666</text>
</svg>

return file:write('/Users/fredatherden/Desktop/svg-test.svg',$svg,map{
                                          'omit-xml-declaration':'no',
                                          'doctype-system':'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd',
                                          'doctype-public':'-//W3C//DTD SVG 1.1//EN'})