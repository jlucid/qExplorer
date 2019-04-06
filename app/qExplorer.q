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


index:startIndex;
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
   applyAttribute[mainDB;heightToPartition[index;chunkSize];;`height;`p#] each `blocks`txInfo`txInputs`txOutputs
  ];
  if[chunkSize~1f+(index mod chunkSize);
    utxoLocation set utxo;
    memoryInfo[]
  ]
 }

.z.ts:{[]
  Hash:.bitcoind.getblockhash[index][`result];
  $[0n~Hash;
     [
       -1(string .z.p)," Caught up with main chain at index: ",string[index];
       -1(string .z.p)," Waiting for next block ",string[index];
       value"\\t 30000";
       writeFreq:1f
     ];
     [
       -1(string .z.p)," Processing Block: ",string[index];
       if[index>300000;writeFreq:100f];
       processBlock[Hash];
       if[writeFreq~1f;
         applyAttribute[refDB;;`txidLookup;`tag;`g#] each 1+til count enumerations;
         applyAttribute[refDB;;`addressLookup;`tag;`g#] each 1+til count enumerations
       ];
       index+:1
     ]
   ];
 }
