saveSplayed:{[Location;Partition;TableName]
  -1(string .z.p)," Saving table: ",string[TableName]," to partition ",string[Partition];
  location:hsym `$"/"sv (string[Location];string[Partition];string[TableName],"/");
  .[location;();$[()~key location;:;,];.Q.en[Location] value TableName]
 };

saveAddrAndTxid:{[db;Keys;Values]
   v:.plyvel.get[db;] each Keys;
   newValues:Values where isNew:v~\:(::);
   newKeys:Keys where isNew:v~\:(::);
   if[all isNew;
     .plyvel.writeBatch[db;Keys;Values];
     :()
   ];
   oldValues:`char$v where not isNew;
   oldKeys:Keys where not isNew;
   appendedValues:oldValues,'" ",'(Values where not isNew);
   .plyvel.writeBatch[db;newKeys,oldKeys;newValues,appendedValues]
 }

openLevelDB:{[dbName;location]
  if[not .plyvel.isClosed[dbName];
    .plyvel.createDB[dbName;location]
  ];
 }


closeLevelDB:{[dbName]
  if[not .plyvel.isClosed[dbName];
    .plyvel.closeDB[dbName]
  ];
 }

saveToLevelDB:{[db]

  if[db~"txidDB";
    saveAddrAndTxid["txidDB";exec txid from txidLookup;string exec height from txidLookup]
  ];

  if[db~"addrDB";
    saveAddrAndTxid["addrDB";exec address from select height by address from addressLookup;" " sv' string each exec height from select height by address from addressLookup]
  ];

  if[db~"utxoDB";
    utxoData:select txuid:(txid,'string[n]),outputValue, address, valueAndAddr:((string[outputValue],'" "),'address) from txOutputs;
    .plyvel.writeBatch["utxoDB";exec txuid from utxoData;exec valueAndAddr from utxoData];
    update txuid:(prevtxid,'string[n]) from `txInputs;
    update spent:1b from `txInputs where not prevtxid like "";
    spentUTXOs:exec txuid from `.[`txInputs] where spent;
    prevValues:`char$.plyvel.get["utxoDB";] each spentUTXOs;
    @[`.;`txInputs;:;`.[`txInputs] lj 1!([] txuid:spentUTXOs; inputValue:"F"$first each " " vs' prevValues;address:last each " " vs' prevValues)];
    .plyvel.delete["utxoDB";] each exec txuid from `.[`txInputs] where spent;
    delete txuid from `txInputs
  ];
 }


applyAttribute:{[Location;Partition;TableName;Column;Attribute]
  .[{[x;y;z] @[x;y;z]};(.Q.par[Location;Partition;TableName];Column;Attribute);{[err] "Cannot apply attribute"}];
 };


clearTable:{[TableName]
  @[`.;TableName;0#]
 };

heightToPartition:{[Height;Width]
  1i + `int$(Height div Width)
 };

ungroupCol:{[tbl;col]
  @[tbl where count each tbl col;col;:;raze tbl col]
 };

memoryInfo:{[]
  0N!.Q.gc[];
  0N!.Q.w[]
 };

printMsg:{[Str]
  -1(string[.z.p]," "),Str
 }

