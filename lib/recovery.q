createCheckpoint:{[]
  printMsg["Creating checkpoint"];

  if[instanceName~`qExplorer;
    utxoLocation:` sv (checkpointDB;`utxoTable);
    checkpointLocation:` sv (checkpointDB;`checkpoint);
    utxoLocation set utxo;
    checkpointLocation set ([] lastIndex:enlist index)
  ];

  if[instanceName~`refDBGenerator;
   refLocation:` sv (checkpointDB;`referenceTracker);
   refLocation set referenceTracker
  ];

  printMsg["Finished creating checkpoint"]
 }

loadCheckpoint:{[]
  printMsg["Loading checkpoint"];

  if[instanceName~`qExplorer;
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
    @[`.;`startIndex;:;1f+first exec lastIndex from lastCheck]
  ];

  if[instanceName~`refDBGenerator;
    refLocation:` sv (checkpointDB;`referenceTracker);
    if[()~key refLocation;
      show "No referenceTracker table found for recovery reboot...exiting";
      exit 0
    ];
   lastRef:get refLocation;
   @[`.;`referenceTracker;:;lastRef];
   :1b
  ];

  printMsg["Finished Loading checkpoint"];
 }
