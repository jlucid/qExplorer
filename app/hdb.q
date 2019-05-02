/////////////////////////////////////////////////////////
/// Provide the path & file, and port in the command
/// line as such --path="databases/mainDB" --port="9000"
/////////////////////////////////////////////////////////

.utl.require"qutil"
.utl.addOpt["path";"*";`hdbPath];
.utl.addOpt["port";"*";`hdbPort];
.utl.parseArgs[];

value"\\p ",hdbPort;

value "\\t 30000"
.z.ts:{
  value"\\l ",hdbPath;
  printMsg["Refreshed ",last[("/" vs hdbPath)]]
 }
