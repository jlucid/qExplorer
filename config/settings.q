startIndex:0f;
writeFreq:500f;
chunkSize:1000f;
applyGroupAttrFreq:50000f;

// Location of mainDB and refDB
// Locations need to be different

mainDB:`:/home/btc/jer/new/qExplorer/mainDB;
refDB:`:/home/btc/jer/new/qExplorer/refDB; 
utxoLocation:`$string[mainDB],"/utxo";

// Credentials for JSON RPC

rpcUsername:"btc";
rpcPassword:"hodl";
