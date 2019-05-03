createCheckpoint:{[]
  printMsg["Creating checkpoint"];
  utxoLocation:` sv (checkpointDB;`utxoTable);
  checkpointLocation:` sv (checkpointDB;`checkpoint);
  utxoLocation set utxo;
  checkpointLocation set ([] lastIndex:enlist index);
  printMsg["Finished creating checkpoint"]
 }

loadCheckpoint:{[]
  printMsg["Loading checkpoint"];

  utxoLocation:` sv (checkpointDB;`utxoTable);
  checkpointLocation:` sv (checkpointDB;`checkpoint);

  if[(()~key checkpointLocation) or ()~key utxoLocation;
      show "No checkpoint table found for recovery reboot...restarting";
      @[`.;`startIndex;:;0f];
      :()
    ];

  lastUTXO:get utxoLocation;
  @[`.;`utxo;:;lastUTXO];
  lastCheck:get checkpointLocation;
  @[`.;`startIndex;:;1f+first exec lastIndex from lastCheck]
 }
