///////////////////////////////////////////////////////////////////////
//  The below .utl.require line can be replaced 
//  with \l /home/path/to/bitcoind.q instead
//////////////////////////////////////////////////////////////////////
.utl.require"qbitcoind"  
.utl.require"qutil"  

///////////////////////////////////////////////////////////////////////
//  The below .utl.require can be replaced 
//  with \l /home/path/to/qExplorer/lib/load.q instead
///////////////////////////////////////////////////////////////////////
.utl.require"qExplorer"


///////////////////////////////////////////////////////////////////////
// Set database locations
///////////////////////////////////////////////////////////////////////
mainDB:hsym `$dbLocation,"mainDB"
checkpointDB:`dbLocation,"checkpointDB"
refDB:hsym `$dbLocation,"refDB"
addrDB:` sv refDB,`addrDB
txidDB:` sv refDB,`txidDB
utxoDB::` sv refDB,`utxoDB


///////////////////////////////////////////////////////////////////////
// Set username and password along with server details for Bitcoind Node
///////////////////////////////////////////////////////////////////////
.bitcoind.initPass[rpcUsername;rpcPassword]
.bitcoind.initHost[nodeAddress];


///////////////////////////////////////////////////////////////////////
// Add an optional command line argument --recover
// If present, then being from last successful checkpoint
// This involves loading the utxo file and setting the startIndex
///////////////////////////////////////////////////////////////////////
loadCheckpoint[];

index:startIndex;
processBlock:{[Hash]
  Block:.bitcoind.getblock[Hash;(enlist `verbosity)!(enlist 2)];
  saveBlockInfo[Block];
  saveTransactionInfo[Block];
  saveTransactionOutputs[Block];
  saveTransactionInputs[Block];
  if[writeFreq~1f+(index mod writeFreq);
   openLevelDB["addrDB";addrDB];
   openLevelDB["txidDB";txidDB];
   openLevelDB["utxoDB";utxoDB];
   saveToLevelDB each ("txidDB";"addrDB";"utxoDB");
   closeLevelDB each ("txidDB";"addrDB";"utxoDB");
   saveSplayed[mainDB;heightToPartition[index;chunkSize];] each `blocks`txInfo`txInputs`txOutputs;
   clearTable each `blocks`txInfo`txInputs`txOutputs`txidLookup`addressLookup;
   applyAttribute[mainDB;heightToPartition[index;chunkSize];;`height;`p#] each `blocks`txInfo`txInputs`txOutputs;
   createCheckpoint[]
  ];
  if[freeMemFreq~1f+(index mod freeMemFreq);
   memoryInfo[]
  ];
 }

.z.ts:{[]
  Hash:.bitcoind.getblockhash[index][`result];
  $[0n~Hash;
     [
       printMsg["Caught up with main chain at index: ",string[index]];
       printMsg["Waiting for next block ",string[index]];
       value"\\t 5000";
       @[`.;`writeFreq;:;2f]
     ];
     [
       printMsg["Processing Block: ",string[index]];
       processBlock[Hash];
       printMsg["Finished Processing Block"];
       index+:1
     ]
   ];
 }
