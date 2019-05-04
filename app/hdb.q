/////////////////////////////////////////////////////////
/// Provide the path & file, and port in the command
/// line as such --path="/opt/q/" 
/// --port="9000" --file="mainDB"
/////////////////////////////////////////////////////////

.utl.require"qutil"
.utl.addOpt["path";"*";`hdbPath];
.utl.addOpt["port";"*";`hdbPort];
.utl.addOpt["file";"*";`hdbFile];
.utl.parseArgs[];

value"\\l ",hdbPath;
value"\\p ",hdbPort;
value"\\l ",hdbFile;

value "\\t 60000";

.z.ts:{
  $[`.[`writeFreq]~1f+(`.[`index] mod `.[`writeFreq]);
    [
      `.[`printMsg]["Not loading ",hdbFile," yet, currently writing to disk"];
      :()
    ];
    [
      `.[`printMsg]["Loading ",hdbFile];
      value"\\l ",hdbPath;
    ]
  ];
 }
