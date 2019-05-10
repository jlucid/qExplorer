///////////////////////////////////////////////////////////////
/// Provide the path & file, and port in the command
/// line as such --path="/opt/q/databases/mainDB" --port="9000"
/// where --file="PATH/TO/lib/explorer.q" (queries script)
///////////////////////////////////////////////////////////////

.utl.require"qutil"
.utl.addOpt["path";"*";`hdbPath];
.utl.addOpt["port";"*";`hdbPort];
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
