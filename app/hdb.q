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

printMsg:{[str]
  -1(string[.z.p]," "),str
 };

value "\\t 30000";
f:{@[system;"l .";show]};

.z.ts:{
  printMsg["Probing for a new partion, refreshing the following database: ",hdbFile];
  f[]
}
