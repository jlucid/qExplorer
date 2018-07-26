saveAddressLookup:{[Location;tbl]
 $[()~key Location;
      [
         -1"Creating new addressLookup table";
        tbl:select height,partition by addresses from tbl;
        /tbl:update height:enlist each height,partition:enlist each partition from tbl;
        Location set update `u#addresses from tbl
      ];
      [
        -1"Appending to addressLookup table";
        list:exec distinct addresses from addressLookup;
        old:h({0!select from addressLookup where addresses in x};list);
        tmpTable:(0!tbl),old;
        tmpTable:select raze height,raze partition by addresses from tmpTable;
        Location upsert tmpTable
      ]
  ];
 }


saveTxidLookup:{[Location;tbl]
 $[()~key Location;
   Location set tbl;
   Location upsert tbl
 ];
 }

// Function used to store block data into the blocks schema
// For the first block, 0, we need to add a value for previousblockhash because its not present
// We remove the tx info before inserting
saveBlockInfo:{[Block]
  if[0f~index;Block[`result],:(!) . enlist@'(`previousblockhash;"NULL")];
  block:update tx:count tx,height:"j"$height,version:"h"$version,time:"P"$string time,mediantime:"P"$string mediantime from Block[`result];
  insert[`blocks;block];
  upsert[`txidLookup;select txid,height:index,partition:heightToPartition[index] from Block[`result][`tx]];
 }

//Fuction used to get the raw transactional for that block
saveTransactionInfo:{[Block]
  Height:Block[`result][`height];
  //Removing locktime as its never populated
  tx:delete locktime,version from update vin:count each vin,vout:count each vout from (trans:`height xcols update height:"j"$Height from Block[`result][`tx]);
  insert[`txInfo;tx];
  //output this as we want to use vin and vout for seperate tables
  trans
 }

//Function to retrive all the inputs for each transaction
saveTransactionInputs:{[trans]
  inputs:select height,txid,vin from trans;
  ip:select height,txid,prevtxid:vin[;`txid],n:vin[;`vout],scriptSig:-8!'vin[;`scriptSig],sequence:vin[;`sequence],txinwitness:vin[;`txinwitness] from ungroupCol[inputs;`vin];
  //txinwitess was only introduced in block 481824. 
  ip:update txinwitness:@[txinwitness;where 0h=type each txinwitness;{";" sv x}] from ip;
  p:1_value each select prevtxid,n from ip;
  coinbase:update n:0i,addresses:enlist "",inputValue:0f from 1#ip;
  ip:update prev_out:{[x;y] select from .bitcoind.getrawtransaction[x;1][`result][`vout] where n= y}.'p from 1_ip;
  ip:update n:`int$n,inputValue:raze prev_out[;`value],addresses:prev_out[;`scriptPubKey][;`addresses] from ip;
  //fix mixed lists, addresses are not always populated.
  ip:update addresses:@[addresses;where 0h=type each addresses;raze/] from ip;
  //Remove pre_out as its replicated in previous block
  ip:coinbase,:delete prev_out from ip;
  insert[`txInputs;ip];
  insert[`addressLookup;select addresses,height:index,partition:heightToPartition[index] from ip where not addresses like ""];}

//Function to retreive all outputs for the block. Requires getBlock with valance set to 2.
saveTransactionOutputs:{[Block]
  Height:Block[`result][`height];
  Data:update vout:{[x;y] update string TXID from update TXID:`$y from x}'[vout;txid] from Block[`result][`tx];
  Data:update height:"j"$Height,n:"i"$n,addresses:scriptPubKey[;`addresses] from raze Data[`vout];
  Data:update scriptPubKey:-8!'scriptPubKey from Data;
  //temp fix for mixed list
  Data:update addresses:@[addresses;where 0h=type each addresses;raze] from Data;
  Data:?[Data;();0b;`height`txid`outputValue`addresses`n`scriptPubKey!`height`TXID`value`addresses`n`scriptPubKey];
  insert[`txOutputs;Data];
  insert[`addressLookup;select addresses,height:index,partition:heightToPartition[index] from Data where not addresses like ""];}

