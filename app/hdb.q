/////////////////////////////////////////////////////////
/// Provide the path & file, and port in the command
/// line as such --path="/opt/q/databases/mainDatabase/" 
/// --port="9000" --file="mainDB"
/////////////////////////////////////////////////////////

.utl.require"qutil"
.utl.addOpt["path";"*";`hdbPath];
.utl.addOpt["port";"*";`hdbPort];
.utl.addOpt["file";"*";`hdbFile];
.utl.parseArgs[];

value"\\l ",hdbPath;
value"\\p ",hdbPort;
value"\\l ",hdbFile

value "\\t 30000"
.z.ts:{
  value"\\l ",hdbPath;
  show["Refreshed ",hdbFile]
 }
