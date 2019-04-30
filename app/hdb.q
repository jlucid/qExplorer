.utl.require"qutil"
.utl.addOpt["path";"*";`hdbPath];
.utl.addOpt["port";"*";`hdbPort];
.utl.addOpt["file";"*";`hdbFile];
.utl.parseArgs[];

value"\\p ",hdbPort;

value "\\t 30000"
.z.ts:{
  value"\\l ",(` sv (hdbPath;hdbFile))
 }
