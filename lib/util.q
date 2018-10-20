
saveSplayed:{[Location;Partition;TableName]
  -1(string .z.p)," Saving table: ",string[TableName]," to partition ",string[Partition];
  location:hsym `$"/"sv (string[Location];string[Partition];string[TableName],"/");
  .[location;();$[()~key location;:;,];.Q.en[Location] value TableName]
 };

applyAttribute:{[Location;Partition;TableName;Column;Attribute]
  @[.Q.par[Location;Partition;TableName];Column;Attribute]
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
