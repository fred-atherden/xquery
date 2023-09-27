declare variable $folder := '/Users/fredatherden/Desktop/biorxiv/b-xml/';
declare variable $xml := for $file in file:list($folder)[ends-with(.,'.xml')]
            return doc($folder||$file);

distinct-values($xml//*:contrib[@contrib-type="author"]/*/name())