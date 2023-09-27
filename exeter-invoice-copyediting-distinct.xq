declare function local:non-distinct-values
  ($seq as xs:anyAtomicType*) as xs:anyAtomicType* {
    for $val in distinct-values($seq)
    return $val[count($seq[. = $val]) > 1]
 };
 
 let $nov-2022 := ('65488','69008','69686','69703','72299','73105','73677','73767','74320','76065','76387','76911','77460','77632','77806','77875','77937','78216','78342','78346','78521','78703','78808','78810','78917','79018','79031','79076','79077','79116','79543','79638','79661','79824','79994','80143','80207','80217','80445','80499','80680','80865','80927','80943','80981','81050','81121','81286','81721','81943','82190','82244','82411','82424','82860','82885','82979','83153','83225','83373','83433','84034','76479','76535','77327','79418','79558','79855','81703','56257','57736','62087','66697','68253','68745','68760','69500','70015','70347','70495','70671','73130','73353','74058','74503','74602','74805','74816','74929','74998','75056','75064','75197','75340','75353','75474','75749','75801','76119','76120','76143','76145','76452','76500','76506','76519','76574','76630','76691','76744','77014','77072','77216','77285','77335','77415','77432','77791','77968','77974','78002','78126','78133','78211','78263','78278','78469','78610','78635','78717','78733','78734','78743','78750','78754','78775','78815','78847','78873','78915','78941','79027','79224','79314','79322','79396','79417','79525','79570','79590','79615','79639','79647','79655','79676','79712','79760','79772','79777','79780','79833','79917','79919','79924','79932','79939','79940','79981','80153','80165','80280','80329','80352','80395','80458','80483','80501','80555','80604','80611','80627','80633','80682','80729','80867','80880','80917','80919','80953','80956','80965','80988','81015','81114','81167','81196','81248','81298','81400','81415','81432','81453','81476','81480','81498','81533','81555','81559','81563','81573','81606','81678','81683','81702','81786','81977','81979','81996','82006','82017','82094','82143','82206','82343','82437','82459','82493','82531','82563','82587','82628','82658','82709','82711','82810','83030','83042','83073','83146','83287','83346','84171','80550','81033','83230','75039','80361','81952','68283','71876','72147','77029','77599','78300','79535','80079','80895','80899','81088','81868','82392')
 
 let $dec-2022 := ('82558','80053','81282','82849','71231','73395','74988','77399','80652','80775','82951','83409','84295','60190','80949','79461','81198','82050','82311','74970','75826','76586','82218','78520','79344','79545','79667','79765','79901','81303','81679','81958','82535','82556','82654','83272','83658','83680','83992','85171','79494','82088','68180','73862','75878','79045','80013','80881','82688','73288','76383','77663','77666','78188','78202','79903','79928','80808','80935','81092','81547','81738','81828','81976','82016','82240','82595','82843','83008','83813','83840','83883','84060','82357','83841','80793','77945','82128','83724','77973','81154','81217','78550','81897','82093','67474','69162','69916','74433','74576','74664','75148','76174','76472','77055','77443','77603','78075','78085','78109','78395','78636','79250','79713','79747','79811','79913','80092','80245','80277','80324','80405','80859','81086','81151','81316','81337','81457','81704','81849','81962','82031','82348','82621','82756','82922','82955','83021','83037','83299','83316','83691','83743','83893','83947','84199','84279','84320','84694','78609','79863','80210','76409','79585','80980','81431','82193','82891','84042')
 
 let $jan-2023 := ('64834','67711','73407','75703','78089','78511','80360','80667','80950','81522','81641','81808','81978','83172','83548','84029','85800','81070','80918','82762','81032','81892','84424','78902','81320','81325','81438','81779','81929','82103','82175','82555','83062','79343','64978','76863','77015','79016','79042','79144','79257','80040','80387','80428','81354','81405','81622','81923','82082','82201','83291','83534','78344','81579','84262','84302','70700','76294','78874','78904','80122','80671','80781','81288','81525','81604','82217','82516','82568','82901','82980','83077','83138','83469','84194','81097','80135','84112','71315','77257','79111','79950','80379','80380','80984','81302','81613','81869','82116','83055','83075','83139','83628','85249','81182','69157','79363','83639','75860','76158','76406','76414','77742','78397','78421','78491','78606','79126','79432','79488','79513','80533','80670','80904','81290','81727','81792','81794','81801','82241','82479','82813','82826','82833','82978','83368','83935','84400','84618','84856','85246','85837','82819','83142','84179','85058','81856')
 
 let $feb-2023 := ('68047','67684','69415','74394','78756','79402','79854','80489','80840','81005','81274','81401','81623','81850','81861','82281','82579','83853','84740','85450','81279','70792','81436','72951','80179','80529','80594','80721','82824','82825','84291','81939','84632','76157','76520','79342','79511','80856','82037','82232','83201','83395','83602','83908','84492','85003','85324','78512','80741','80768','81177','81212','81692','82611','82895','83623','84708','77345','78729','79299','79908','80640','81463','81532','81605','81983','82112','82118','82785','84245','83654','85537','74899','75825','77699','78349','81184','81188','81392','81569','81961','82015','82467','82821','82934','83044','83149','83662','83761','84051','84594','84621','85103','86258','82811','84319','68670','69521','71154','72923','75007','75631','76425','77441','77455','77562','77701','78689','78787','79013','79152','79196','79642','79742','79768','79946','80100','80281','80317','80647','80809','81048','81150','81445','81492','81723','81804','82207','82263','82283','82546','82626','82641','82705','82947','83018','83045','83108','83133','83176','83207','83330','83442','83486','83561','83815','83928','83976','84143','84327','84477','85836','82998','71235','84155','77976','81843','82537','83496')
 
 let $mar-2023 := ('68531','74434','76300','77733','78836','78908','79925','80328','82345','83129','83364','83652','83685','84056','84190','84853','84877','85135','75191','82364','82690','81656','82431','83116','84791','85035','87444','79452','80757','81446','82301','82818','83479','83616','84488','84878','85182','85289','85413','86971','77578','78299','78629','80942','81795','81810','82120','82250','82584','82703','82925','83035','83217','83533','83970','84085','85345','86139','78877','80468','80517','81224','81577','82395','83398','83529','83694','83855','84391','77507','78360','78381','78530','78654','79271','79305','79408','79964','80246','80500','80660','80663','80669','80819','81127','81318','81360','81549','81780','81818','81926','82142','82178','82227','82580','82728','82916','83023','83053','83159','83285','83365','83444','83464','83516','83524','83578','83593','83618','83710','83734','83760','83768','83796','83806','83979','84043','84147','84157','84168','84263','84379','84412','84415','84796','84991','85082','85114','85416','85464','85739','86002','86284','86416','86447','86696','86697','86807','86885','87047','87054','87366','87504','87507','87888','87987')
 
 let $apr-2023 := ('66627','76182','77659','78280','78942','79380','80160','80168','80403','80466','80479','80560','81080','81099','81511','81629','81743','81855','81858','81982','82367','82435','82498','82599','82649','82676','82786','82969','83012','83118','83205','83232','83426','83530','83545','83627','83656','83727','83739','83845','83876','83966','84151','84205','84238','84395','85317','85488','85542','85609','85641','85754','85821','86049','81067','81919','83477','84006','84057','85120','85202','85302','85727','86030','86206','88080','84375','84512','84493','74915','75624','79620','83161','84041','84139','84743','85439','79672','81370','84860','85703','77690','82410','84167','84382','84669','84757','84983','85264','85304','81197','85260','81123','83867','84019','85145','85492','86273','86015','78100','79541','79862','82502','82996','83810','85064','66765','80639','85167','73786','74913','78544','80254','80365','80900','81084','81716','81717','81752','82057','82111','82447','82608','83094','83209','83338','83600','83604','83664','83888','83946','84070','84589','85241','85521','85594','85679','85902','85970','86001','86413','88329','76645','82938')
 
 let $may-2023 := ('83971','79444','75586','75726','76927','77262','78392','78601','79165','79238','79386','79827','80063','80152','80653','81112','81173','81646','81681','81774','81826','81916','81992','84024','84088','84280','84312','84360','84370','84531','84566','84570','84648','84658','84664','84693','84760','84778','84797','84911','85039','85111','85117','85142','85251','85262','85328','85410','85443','85553','85633','85725','85767','85779','85847','85993','86023','86032','86066','86067','86075','86283','86299','86394','86430','86504','86556','86628','86842','88749','77408','78335','78558','80156','80875','81170','81980','82249','82290','82324','82376','82377','82412','82450','82533','82538','82674','82954','82991','83069','83345','83353','83470','83484','83792','83793','83835','83842','84036','84045','84149','84330','84333','84396','84491','84552','84759','84815','84910','85092','85107','85108','85136','85243','85307','85714','86166','86291','86295','86325','86336','86527','87495','88204','80878','82390','86014','86548','84683','84691','88654','82863','85041','85605')
 
  let $jun-2023 := ('83100','83107','83328','83393','83538','83659','84338','84685','84822','85006','86496','86699','87026','87181','84792','84831','88898','80075','81467','83152','83951','84630','84864','85009','86176','78695','80923','81119','81499','81863','83543','83884','84446','86562','86617','87192','87253','87537','68221','83957','84604','84918','85795','84805','79565','82850','84808','85735','85971','86373','84364','84357','82384','82426','82734','83289','84257','84315','88273','85649','85415','85547','77514','79648','80303','80443','80628','81012','81521','82386','83870','84072','84888','84967','85104','85348','85432','85792','86127','86369','86454','86514','87086','88058','81289','84874','87178','69322','69611','69779','72681','76584','76609','78187','78515','79815','79834','79840','80767','80854','81241','81280','81418','81907','82333','82401','82483','82490','82543','82598','82617','82619','82675','82683','82748','82874','82933','82959','83004','83276','83413','83532','83584','83606','83660','83856','83874','84065','84135','84204','84209','84392','84508','84537','84645','85011','85079','85258','85414','85545','85752','85760','86103','88345','89185','83361','82596','85183','81464','82593','85882','86130')
  
  let $jul-2023 := ('75401','77513','80090','80263','83239','83637','83891','84322','84988','85193','85575','87521','88187','89702','81830','84387','83764','85093','85487','86936','79812','80661','81011','83064','83083','83868','84673','84782','84969','86784','86961','86990','87468','87705','87860','80494','87098','80038','81701','85595','85814','86585','82970','83843','84790','85875','86633','87616','87672','78546','80447','82210','83005','84899','85188','85309','85422','86182','86327','87463','87865','87902','88492','64904','78518','79179','79450','79743','81966','82428','82504','82597','82697','82983','83385','83861','84077','84108','84753','84850','84881','84961','85208','85316','85550','85596','85748','85773','85872','86022','86029','86125','86129','86324','86329','86333','86636','86943','86972','87037','87125','87623','87696','87714','88210','88310','89160')
  
  let $aug-2023 := ('78554','80250','83541','83588','84710','85435','85590','85618','85867','86126','86183','86670','86976','87038','87188','87357','89066','90006','90773','83187','87133','89951','85008','81090','82297','83981','85682','85724','86090','86136','86358','86635','81639','82115','84711','85036','85143','85338','85647','86035','86852','87306','88350','85293','78205','84092','83163','83286','83831','85898','86116','86453','86944','87016','88951','84679','63402','75628','77364','80777','81805','82069','83451','84260','84324','84752','85024','85131','85165','85263','85332','85380','85459','85597','85659','85878','86200','86233','86439','86512','86913','87169','87283','88206','88875','90234','85980','90189','21221','85444','85743','85832','82566','82717','83974','83975','84296','85910','67177','73189','75906','77009','80710','81407','82184','83140','83342','83644','84414','85140','85494')
 
 return local:non-distinct-values(($nov-2022,$dec-2022,$jan-2023,$feb-2023,$mar-2023,$apr-2023,$may-2023,$jun-2023,$jul-2023,$aug-2023))