.utl.require"qExplorer"
\t 2000
\p 23456
value "\\l ",1 _ string mainDB;
.z.zd:(17;2;6);


////////////////////////////////////////////////////
// referenceTracker table is used to track which
// blocks have been processed and which are pending
////////////////////////////////////////////////////

referenceTracker:([]
  partition:`int$();
  height:`int$();
  partitionSet:`boolean$();  // Partition contains a 1000 blocks and wont be modified anymore
  processedRef:`boolean$()   // Whether reference data has been generated for block
 )


////////////////////////////////////////////////////
// extractTxidInfo: Function used to extract data from mainDB to populate txidLookup
// extractAddrInfo: Function used to extract data from mainDB to populate addressLookup
////////////////////////////////////////////////////

extractTxidInfo:{[input]
  Data:select txid,height,partition:heightToPartition[height;chunkSize],tag:`$-3#'txid from txInfo where int=input[`partition], height in input[`height];
  insert[`txidLookup;Data]
 }

extractAddrInfo:{[input]
  Data:select address,height,partition:heightToPartition[height;chunkSize],tag:`$-3#'address from txInputs where int=input[`partition], height in input[`height], not address like "";
  Data,:select address,height,partition:heightToPartition[height;chunkSize],tag:`$-3#'address from txOutputs where int=input[`partition], height in input[`height], not address like "";
  insert[`addressLookup;Data]
 }


////////////////////////////////////////////////////
// writeRefDB: Main function alled by the timer
// It takes as input a partition number and list of block heights
// and used that information to perform lookups on the mainDB
// to populated the txidLookup and addressLookup tables
// These tables are written to disk within same funcion
// and internal tables are cleared
////////////////////////////////////////////////////

writeRefDB:{[input]
  
  show "Processing Partition: ",string[input`partition]," Min Height: ",string[min input`height], " Max Height: ",string[max input`height];

  heightsCol:hsym `$string[`.[`mainDB]], "/",string[input`partition], "/txOutputs/height";
  if[()~key heightsCol;
    show "No txOutputs table present yet";
    :()
  ];

  if[not `p~attr get heightsCol;
   show"No parted attribute present, waiting...";
   :()
  ];

  extractTxidInfo[input];
  saveGroups[refDB;`txidLookup;txidLookup];
  @[`.;`txidLookup;0#];
  extractAddrInfo[input];
  saveGroups[refDB;`addressLookup;addressLookup];
  @[`.;`addressLookup;0#];

  update processedRef:1b from `referenceTracker where partition in input[`partition], height in input[`height]
 }


////////////////////////////////////////////////////
// .z.ts: Main timer which gets called every few seconds
// and searches the mainDB for any newly written blocks
// New blocks which have had their parted attribute applied
// will be processed immediately
////////////////////////////////////////////////////

.z.ts:{[]

  if[()~key mainDB;
   show "No partition created in mainDB yet";
   :()
  ];

  value "\\l ",1 _ string mainDB;
  allPartitions:asc "I"$string each key mainDB;
  completedPartitions:distinct exec partition from referenceTracker where (last;processedRef) fby partition, chunkSize=(count;i) fby partition;
  watchPartitions:allPartitions except completedPartitions;

  {[Partition]

    allHeights:distinct get hsym `$string[`.[`mainDB]], "/",string[Partition], "/txOutputs/height";
    completedHeights:exec height from referenceTracker where partition=Partition, processedRef;
    processHeights:allHeights except completedHeights;
    if[count processHeights;
      insert[`referenceTracker;([] partition:(count processHeights)#Partition;height:processHeights)]
    ];

  } each watchPartitions;

  writeRefDB each 0!select height by partition from referenceTracker where not processedRef;

  applyAttribute[refDB;;`txidLookup;`tag;`g#] each 1+til count enumerations;
  applyAttribute[refDB;;`addressLookup;`tag;`g#] each 1+til count enumerations;

  newlyCompleted:distinct exec partition from referenceTracker where chunkSize=(count;i) fby partition, (last;processedRef) fby partition;
  update partitionSet:1b from `referenceTracker where partition in newlyCompleted;
  .Q.chk[refDB]
 }
