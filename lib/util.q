k)append:{[d;p;t] if[~&/.Q.qm'r:+.Q.en[d]`. t;'`unmappable];{[d;t;x] @[d;x;,;t[x]]}[d:.Q.par[d;p;t];r]'!r;@[d;`.d;:;!r];t}

saveParted:{[Location;Partition;PartedBy;TableName]
  -1(string .z.p)," Saving table ",string[TableName]," on partition ",string[Partition];
  tblLocation:hsym `$"/"sv (string[Location];string[Partition];string[TableName];"");
  $[()~key tblLocation;
    [
      -1(string .z.p)," Creating table";
      .[.Q.dpft;(Location;Partition;PartedBy;TableName);{[x;y;z] -2(string .z.p)," Error: Saving table ",string[y]," on partition ",string[z],", message: ",x}[;TableName;Partition]]
    ];
    [
      -1(string .z.p)," Appending table to: ",string tblLocation;
      @[`.;TableName;:;`height xcols `.[TableName]];
      append[Location;Partition;TableName]
    ]
  ];
 };


sortTblOnDisk:{[Location;Partition;TableName;Col]
  -1(string .z.p)," Sorting table ",string[TableName]," on partition ",string[Partition];
  tblLocation:hsym `$"/"sv (string[Location];string[Partition];string[TableName];"");
  Col xasc tblLocation
 }


heightToPartition:{[Height;Width]
  1i + `int$(Height div Width)
 };

ungroupCol:{[tbl;col]
  @[tbl where count each tbl col;col;:;raze tbl col]
 };
