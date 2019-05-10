/////////////////////////////////////////////////////////
/// Provide the path & file, and port in the command
/// line as such --path="/opt/q/databases/mainDatabase/mainDB" 
/// --port="9000" --file="PATH/TO/lib/explorer.q"
/////////////////////////////////////////////////////////

.utl.require"qutil"
.utl.addOpt["path";"*";`hdbPath];
.utl.addOpt["port";"*";`hdbPort];
.utl.addOpt["file";"*";`hdbFile];
.utl.parseArgs[];

value"\\l ",hdbFile;
value"\\p ",hdbPort;
value"\\l ",hdbPath;

printMsg:{[str]
  -1(string[.z.p]," "),str
 };

value "\\t 30000";
f:{@[system;"l .";show]};

.z.ts:{
  printMsg["Probing for a new partion, refreshing the following database: ",last("/" vs hdbPath)];
  f[]
}
