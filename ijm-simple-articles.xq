let $set := ("/ijm/ijm-00207.xml", "/ijm/ijm-00206.xml", "/ijm/ijm-00199.xml", "/ijm/ijm-00204.xml", "/ijm/ijm-00205.xml", "/ijm/ijm-00198.xml", "/ijm/ijm-00201.xml", "/ijm/ijm-00200.xml", "/ijm/ijm-00202.xml", "/ijm/ijm-00203.xml", "/ijm/ijm-00208.xml", "/ijm/ijm-00197.xml")

for $x in collection('ijm')//*:article[base-uri()=$set and not(descendant::*:app) and descendant::*:fig and descendant::*:table-wrap]
return $x