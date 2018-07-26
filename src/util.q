
//k)append_orig:{[d;p;t] if[~&/.Q.qm'r:+.Q.en[d]`. t;'`unmappable];{[d;t;x]$[max$["b"] x=`scriptSig`scriptPubKey;@[d;x;:;(.:`$($:d),"/",($:x)) , t[x]];@[d;x;,;t[x]]]}[d:.Q.par[d;p;t];r]'!r;@[d;`.d;:;!r];t}

k)append:{[d;p;t] if[~&/.Q.qm'r:+.Q.en[d]`. t;'`unmappable];{[d;t;x] @[d;x;,;t[x]]}[d:.Q.par[d;p;t];r]'!r;@[d;`.d;:;!r];t}

saveParted:{[Location;Partition;PartedBy;TableName]
  -1"Saving table ",string[TableName]," on partition ",string[Partition];
  tblLocation:hsym `$"/"sv (string[Location];string[Partition];string[TableName];"");
  $[()~key tblLocation;
    [
      -1"Creating table";
      .[.Q.dpft;(Location;Partition;PartedBy;TableName);{[x;y;z] -2"Error: Saving table ",string[y]," on partition ",string[z],", message: ",x}[;TableName;Partition]] 
    ];
    [ 
      -1"Appending table to: ",string tblLocation;
      @[`.;TableName;:;`height xcols `.[TableName]];
      append[Location;Partition;TableName]
    ]
  ]; 
 };

heightToPartition:{[Height]
  1i + `int$(Height div chunkSize)
 };

ungroupCol:{[tbl;col]  
  @[tbl where count each tbl col;col;:;raze tbl col]
 };
