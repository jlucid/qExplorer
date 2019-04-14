loadFile:{value "\\l ",x}
$[not ""~BLOCK_HOME:getenv[`BLOCK_HOME];
  [
   loadFile BLOCK_HOME,"/tbls/addressLookup.q";
   loadFile BLOCK_HOME,"/tbls/blocks.q";
   loadFile BLOCK_HOME,"/tbls/txidLookup.q";
   loadFile BLOCK_HOME,"/tbls/txInfo.q";
   loadFile BLOCK_HOME,"/tbls/txInputs.q";
   loadFile BLOCK_HOME,"/tbls/txOutputs.q";
   loadFile BLOCK_HOME,"/tbls/utxo.q";
   loadFile BLOCK_HOME,"/config/settings.q";
   loadFile BLOCK_HOME,"/lib/util.q";
   loadFile BLOCK_HOME,"/lib/save.q";
   loadFile BLOCK_HOME,"/lib/explorer.q";
   loadFile BLOCK_HOME,"/lib/recovery.q"
  ];
  [
   -2 "Error -> Environmental variable BLOCK_HOME not set";
   exit 1
  ]
 ];
