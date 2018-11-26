startIndex:0f;
writeFreq:500f;
chunkSize:1000f;
applyGroupAttrFreq:50000f;

// Location of mainDB and refDB
// Locations need to be different

mainDB:`:.;
refDB:`:.; 
utxoLocation:`$string[mainDB],"/utxo";

// Credentials for JSON RPC

rpcUsername:"";
rpcPassword:"";
