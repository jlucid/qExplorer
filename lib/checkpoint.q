createCheckpoint:{[]
  printMsg["Creating checkpoint"];
  utxoLocation:` sv (checkpointDB;`utxoTable);
  checkpointLocation:` sv (checkpointDB;`checkpoint);
  utxoLocation set utxo;
  checkpointLocation set ([] lastIndex:enlist index);
  printMsg["Finished creating checkpoint"]
 }

loadCheckpoint:{[startIndex]
  printMsg["Loading checkpoint"];
  utxoLocation:` sv (checkpointDB;`utxoTable);
  checkpointLocation:` sv (checkpointDB;`checkpoint);
  if[()~key utxoLocation;
    show "No utxo table found, beginning from index 0f";
    :0f
  ];
  lastUTXO:get utxoLocation;
  @[`.;`utxo;:;lastUTXO];
  lastCheck:get checkpointLocation;
  :1f+first exec lastIndex from lastCheck
 }
