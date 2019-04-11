///////////////////////////////////////////////////////////////////////
//  The below .utl.require can be replaced 
//  with \l /home/path/to/bitcoind.q instead
//////////////////////////////////////////////////////////////////////
.utl.require"qbitcoind"  

///////////////////////////////////////////////////////////////////////
//  The below .utl.require can be replaced 
//  with \l /home/path/to/qExplorer/lib/load.q instead
///////////////////////////////////////////////////////////////////////
.utl.require"qExplorer"


\t 100
\p 54354
\g 1
\c 20 150
\P 12
.z.zd:(17;2;6);


///////////////////////////////////////////////////////////////////////
// Set username and password along with server details for Bitcoind Node
///////////////////////////////////////////////////////////////////////
.bitcoind.initPass[rpcUsername;rpcPassword]
.bitcoind.initHost[nodeAddress];


///////////////////////////////////////////////////////////////////////
// If startIndex is 0f, being initial block download
// If startIndex is not 0f, load utxo from last checkpoint and set index
///////////////////////////////////////////////////////////////////////
index:loadCheckpoint[startIndex];


processBlock:{[Hash]
  Block:.bitcoind.getblock[Hash;(enlist `verbosity)!(enlist 2)];
  saveBlockInfo[Block];
  saveTransactionInfo[Block];
  saveTransactionOutputs[Block];
  saveTransactionInputs[Block];
  if[writeFreq~1f+(index mod writeFreq);
   updateUTXO[];
   saveSplayed[mainDB;heightToPartition[index;chunkSize];] each `blocks`txInfo`txInputs`txOutputs;
   saveGroups[refDB;`txidLookup;txidLookup];
   saveGroups[refDB;`addressLookup;addressLookup];
   .Q.chk[refDB];
   clearTable each `blocks`txInfo`txInputs`txOutputs`txidLookup`addressLookup;
   applyAttribute[mainDB;heightToPartition[index;chunkSize];;`height;`p#] each `blocks`txInfo`txInputs`txOutputs;
   memoryInfo[];
   createCheckpoint[]
  ]
 }

.z.ts:{[]
  Hash:.bitcoind.getblockhash[index][`result];
  $[0n~Hash;
     [
       printMsg["Caught up with main chain at index: ",string[index]];
       printMsg["Waiting for next block ",string[index]];
       value"\\t 30000";
       @[`.;`writeFreq;:;1f]
     ];
     [
       printMsg["Processing Block: ",string[index]];
       if[(index>350000f) & not (writeFreq~1f);@[`.;`writeFreq;:;250f]];
       processBlock[Hash];
       printMsg["Finished Processing Block"];
       index+:1
     ]
   ];
 }
