.utl.require"qutil"
.utl.addOpt["path";"*";`hdbPath];
.utl.addOpt["port";"*";`hdbPort];
.utl.parseArgs[];

value"\\l ",hdbPath;
value"\\p ",hdbPort
