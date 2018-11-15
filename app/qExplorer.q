.utl.require"qbitcoind"
.utl.require"qExplorer"

\t 100
\p 54354
\g 1
\c 20 150
\P 12
.z.zd:(17;2;6);

.bitcoind.initPass[rpcUsername;rpcPassword]
index:startIndex;

characters:"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
enumerations:`$characters cross characters;

// Function called on a timer to process a block
// Currently every 10 (chunkSize) blocks we save to disk and clear out tables
processBlock:{[Hash]
  Block:.bitcoind.getblock[Hash;(enlist `verbosity)!(enlist 2)];
  saveBlockInfo[Block];
  saveTransactionInfo[Block];
  saveTransactionOutputs[Block];
  saveTransactionInputs[Block];
  if[writeFreq~1f+(index mod writeFreq);
   updateUTXO[];
   saveSplayed[hdbLocation;heightToPartition[index;chunkSize];] each `blocks`txInfo`txInputs`txOutputs;
   saveGroups[refdbLocation;`txidLookup;txidLookup];
   saveGroups[refdbLocation;`addressLookup;addressLookup];
   clearTable each `blocks`txInfo`txInputs`txOutputs`txidLookup`addressLookup
  ];
  if[chunkSize~1f+(index mod chunkSize);
    utxoLocation set historicalUTXO;
    applyAttribute[hdbLocation;heightToPartition[index;chunkSize];;`height;`p#] each `blocks`txInfo`txInputs`txOutputs;
    memoryInfo[]
  ];
  if[applyGroupAttrFreq~1f+(index mod applyGroupAttrFreq);
    applyAttribute[refdbLocation;;`txidLookup;`parted;`g#] each 1+til count enumerations;
    applyAttribute[refdbLocation;;`addressLookup;`parted;`g#] each 1+til count enumerations;
    (.Q.dd[refdbLocation]`enumerations) set enumerations
  ];
 }

// Timer function - Checks for new blocks to process
.z.ts:{[]
  Hash:.bitcoind.getblockhash[index][`result];
  if[not 0n~Hash;
       -1(string .z.p)," Processing Block: ",string[index];
       processBlock[Hash];
       index+:1
   ];
 }
