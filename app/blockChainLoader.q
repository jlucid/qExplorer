.utl.require "qbitcoind"
.utl.require getenv[`BLOCK_HOME]
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
