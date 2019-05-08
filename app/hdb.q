/////////////////////////////////////////////////////////
/// Provide the path & file, and port in the command
/// line as such --path="databases/mainDB" --port="9000"
/////////////////////////////////////////////////////////

.utl.require"qutil"
.utl.addOpt["path";"*";`hdbPath];
.utl.addOpt["port";"*";`hdbPort];
.utl.parseArgs[];

value"\\l ",hdbPath;
value"\\p ",hdbPort;
value"\\l ",hdbFile;

printMsg:{[str]
  -1(string[.z.p]," "),str
 };

value "\\t 30000";

f:{@[system;"l .";show]};

.z.ts:{
  printMsg["Probing for a new partion, refreshing the following database: ",hdbFile];
  f[]
}
