saveSplayed:{[Location;Partition;TableName]
  -1(string .z.p)," Saving table: ",string[TableName]," to partition ",string[Partition];
  location:hsym `$"/"sv (string[Location];string[Partition];string[TableName],"/");
  .[location;();$[()~key location;:;,];.Q.en[Location] value TableName]
 };

saveSplayed2:{[Location;Partition;TableName;Table]
  /-1(string .z.p)," Saving table: ",string[TableName]," to partition ",string[Partition];
  location:hsym `$"/"sv (string[Location];string[Partition];string[TableName],"/");
  .[location;();$[()~key location;:;,];.Q.en[Location] Table]
 };

saveGroups:{[Location;TableName;Table]
  $[`addressLookup~TableName;
    Parts:asc distinct exec Group from Table:update Group:`$-2#'address from Table;
    Parts:asc distinct exec Group from Table:update Group:`$-2#'txid from Table
  ];
  Table:update `p#Group from `Group xasc distinct Table;
  -1(string .z.p)," Saving table: ",string[TableName];
  saveSplayed2[Location;;TableName;]'[1+enumerations?Parts;{[x;y] delete Group from select from x where Group in y}[Table;] each Parts]
 }

applyAttribute:{[Location;Partition;TableName;Column;Attribute]
  .[{[x;y;z] @[x;y;z]};(.Q.par[Location;Partition;TableName];Column;Attribute);{[err] "Cannot apply attribute"}];
 };

sortTblOnDisk:{[Location;Partition;TableName;Col]
  -1(string .z.p)," Sorting table ",string[TableName]," on partition ",string[Partition];
  location:hsym `$"/"sv (string[Location];string[Partition];string[TableName];"");
  Col xasc location;
  .Q.gc[]
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
