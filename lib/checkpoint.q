createCheckpoint:{[]
  printMsg["Creating checkpoint"];
  utxoLocation set utxo;
  checkpointLocation set ([] lastIndex:enlist index);
  printMsg["Finished creating checkpoint"]
 }

loadCheckpoint:{[startIndex]
  printMsg["Loading checkpoint"];
  $[startIndex~0f;
    [
      show"Index in settings.q is 0f, not loading checkpoint";
      :startIndex
    ];  
    [
      show"Index in settings.q is not 0f, loading index from checkpoint folder";
      lastUTXO:get utxoLocation;
      @[`.;`utxo;:;lastUTXO];
      lastCheck:get checkpointLocation;
      :1f+first exec lastIndex from lastCheck
    ]
  ]
 }

