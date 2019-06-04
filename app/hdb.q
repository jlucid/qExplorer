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

//////////////////////////////////////////////////////////
/// Let's track whose in here and what they've been up to.
//////////////////////////////////////////////////////////

currentConnections: 1!flip `handle`time`user`IP`numberMessages!"its*i"$\:();
query: flip `handle`qry`startTime`endTime`duration`success`error!"i*ppnb*"$\:();

/ insert a row into the currentConnections table with client information
.z.po:{insert[`currentConnections;(.z.w;.z.t;.z.u;`int$vs[0x00;.z.a];0i)];printMsg["Handle ",string[.z.w]," has connected to the HDB"]};

/ Delete connection when client closes connection
.z.pc:{delete from `currentConnections where handle=x;printMsg["Handle ",string[x]," has exited their session"]};

/ increment the numberMessages field by one for the appropriate row
.z.pg:{
    qrystr:$[10h=type x;x;.Q.s1 x];
    update numberMessages+1 from `currentConnections where handle=.z.w;
    startTime:.z.p;
    res:@[{res:value x;(1b;res)};x;{(0b;x)}];
    `query upsert enlist `handle`qry`startTime`endTime`duration`success`error!(.z.w;qrystr;startTime;.z.p;.z.p-startTime;res[0];$[res[0];enlist" ";res[1]]);
    if[not res[0];'res[1]];
    :res[1];
    };

/ increment the numberMessages field by one row from the appropriate row
.z.ps:{update numberMessages:numberMessages+1 from `currentConnections where handle=.z.w;value x;}
