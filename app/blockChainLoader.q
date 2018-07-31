// Load the required qbitcoind library
// If .utl namespace is present then assume it can be loaded using the qutil library
$[`utl in key`;
  [
    -1 "Loading qbitcoind library using qutil package";
    @[.utl.require;"qbitcoind";{[err] -1 "Failed to load qbitcoind using qutil library:",err;exit 1}]
  ]; 
  [
    -1 "Loading qbitcoind library using load.q";
    @[value;"\\l ",getenv[`QBITCOIND_HOME],"/lib/load.q";{[err] -1 "Failed to load qbitcoind using qutil library:",err;exit 1}]
  ]
 ];


-1 "Loading required table schemas, config settings and source files";
@[value;"\\l ",getenv[`BLOCK_HOME],"/lib/load.q";{[err] -1 "Failed to load required q files::",err;exit 1}];


.bitcoind.initPass[rpcUsername;rpcPassword]
hdbHandle:hopen hdbPort;
index:startIndex;

// Function called on a timer to process a block
processBlock:{[Hash]
  Block:.bitcoind.getblock[Hash;2];
  saveBlockInfo[Block];
  trans:saveTransactionInfo[Block];
  saveTransactionInputs[trans];
  saveTransactionOutputs[Block];
  if[writeFreq~1f+(Block[`result][`height] mod writeFreq);
   saveParted[hdbLocation;heightToPartition[index];`height;] each (`blocks`txInfo`txInputs`txOutputs);
   saveTxidLookup[txidLocation;txidLookup];
   saveAddressLookup[addressLocation;addressLookup];
   @[`.;;0#] each `blocks`txInfo`txInputs`txOutputs`txidLookup`addressLookup;
   update `u#txid from `txidLookup;
   update `u#addresses from `addressLookup;   
  .Q.gc[];
  ];
  if[chunkSize~1f+(Block[`result][`height] mod chunkSize);
   {[Tbl;Ix] @[.Q.par[hdbLocation;heightToPartition[Ix];Tbl];`height;`p#]}[;index] each `blocks`txInfo`txInputs`txOutputs
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
