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

  if[()~key checkpointLocation;
    show "No checkpoint table found for recovery reboot...exiting";
    exit 0
  ];
  if[()~key utxoLocation;
    show "No utxo table found for recovery reboot...exiting";
    exit 0
  ];

  lastUTXO:get utxoLocation;
  @[`.;`utxo;:;lastUTXO];
  lastCheck:get checkpointLocation;
  :1f+first exec lastIndex from lastCheck
 }
