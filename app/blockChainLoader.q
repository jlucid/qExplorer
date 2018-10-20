// Load the required qbitcoind library
// If .utl namespace is present then assume it can be loaded using the qutil library
$[`utl in key`;
  [
    -1 "Loading qbitcoind library using qutil package";
    @[.utl.require;"qbitcoind";{[err] -1 "Failed to load qbitcoind using qutil library:",err;exit 1}]
  ]; 
  [
    -1 "Loading qbitcoind library using load.q";
    @[value;"\\l ",getenv[`QBITCOIND_HOME],"/lib/bitcoind.q";{[err] -1 "Failed to load qbitcoind using qutil library:",err;exit 1}]
  ]
 ];


-1 "Loading required table schemas, config settings and source files";
@[value;"\\l ",getenv[`BLOCK_HOME],"/lib/load.q";{[err] -1 "Failed to load required q files::",err;exit 1}];


.bitcoind.initPass[rpcUsername;rpcPassword]
index:startIndex;


// Function called on a timer to process a block
// Currently every 10 (chunkSize) blocks we save to disk and clear out tables
processBlock:{[Hash]
  Block:.bitcoind.getblock[Hash;(enlist `verbosity)!(enlist 2)];
  saveBlockInfo[Block];
  saveTransactionInfo[Block];
  saveTransactionOutputs[Block];
  saveTransactionInputs[Block];
  if[writeFreq~1f+(Block[`result][`height] mod writeFreq);
   updateUTXO[];
   saveSplayed[hdbLocation;heightToPartition[index;chunkSize];] each `blocks`txInfo`txInputs`txOutputs;
   saveSplayed[lookupLocation;heightToPartition[index;lookupChunkSize];] each `txidLookup`addressLookup;
   clearTable each `blocks`txInfo`txInputs`txOutputs`txidLookup`addressLookup
  ];
  if[chunkSize~1f+(Block[`result][`height] mod chunkSize);
    utxoLocation set historicalUTXO;
    applyAttribute[hdbLocation;heightToPartition[index;chunkSize];;`height;`p#] each `blocks`txInfo`txInputs`txOutputs;
    memoryInfo[]
  ];
  if[lookupChunkSize~1f+(Block[`result][`height] mod lookupChunkSize);
    sortTblOnDisk[lookupLocation;heightToPartition[index;lookupChunkSize];`txidLookup;`parted];
    sortTblOnDisk[lookupLocation;heightToPartition[index;lookupChunkSize];`addressLookup;`parted];
    applyAttribute[lookupLocation;heightToPartition[index;lookupChunkSize];;`parted;`p#] each `txidLookup`addressLookup
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
