let $deposit-dir := '/Users/fredatherden/Desktop/rp-dois/'

let $files := for $folder in file:list($deposit-dir)[.!='.DS_Store']
              return file:list($deposit-dir||$folder)[.!='.DS_Store']
              
let $revised := for $file in $files[matches(.,'_[2-9]')]
                return substring-before($file,'.xml')

return $revised