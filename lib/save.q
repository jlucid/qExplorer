characters:"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
enumerations:`$characters cross characters;
(.Q.dd[refDB]`enumerations) set enumerations;

// Function used to store block data into the blocks schema
// For the first block, 0, we need to add a value for previousblockhash because its not present
// We remove the tx info before inserting
saveBlockInfo:{[Block]
  if[0f~index;Block[`result],:(!) . enlist@'(`previousblockhash;"NULL")];
  block:update tx:count tx,height:"j"$height,version:"j"$version,time:"P"$string time,mediantime:"P"$string mediantime from Block[`result];
  block:update nextblockhash:count[i]#enlist"" from (enlist block) where 10h<>type each nextblockhash;
  insert[`blocks;delete nTx from block];
 }

//Fuction used to get the raw transactional for that block
saveTransactionInfo:{[Block]
  Height:Block[`result][`height];
  tx:delete version from update vin:count each vin,vout:count each vout from (`height xcols update height:"j"$Height from Block[`result][`tx]);
  insert[`txidLookup;select txid,height,partition:heightToPartition[index;chunkSize],tag:`$-3#'txid from tx];
  insert[`txInfo;tx];
 }

//Function to retreive all outputs for the block. Requires getBlock with valance set to 2.
saveTransactionOutputs:{[Block]
  Height:Block[`result][`height];
  outputs:(`height xcols select height:"j"$Height,txid,vout from Block[`result][`tx]);
  outputs:update n:"i"$vout[;`n],scriptPubKey:vout[;`scriptPubKey],outputValue:vout[;`value],address:vout[;`scriptPubKey;`addresses] from ungroupCol[outputs;`vout];
  outputs:update scriptPubKey:-8!'scriptPubKey from outputs;
  outputs:update address:@[address;where 0h=type each address;raze] from outputs;
  outputs:select height,txid,outputValue,address,n,scriptPubKey from outputs;
  utxoData:select txuid:(txid,'string[n]),inputValue:outputValue,address from outputs;
  insert[`txOutputs;outputs];
  insert[`addressLookup;select address,height,partition:heightToPartition[index;chunkSize],tag:`$-3#'address from outputs where not address like ""];
  upsert[`utxo;utxoData];
  update utxoIndex:i from `utxo;
  -1(string .z.p)," UTXO Count: ",(string count utxo);
 }

//Function to retrive all the inputs for each transaction
saveTransactionInputs:{[Block]
  Height:Block[`result][`height];
  inputs:(`height xcols update height:"j"$Height from Block[`result][`tx]);
  inputs:select height,txid,prevtxid:vin[;`txid],n:`int$vin[;`vout],scriptSig:-8!'vin[;`scriptSig],sequence:vin[;`sequence],txinwitness:vin[;`txinwitness] from ungroupCol[inputs;`vin];
  coinbase:update n:0i,address:enlist "",inputValue:0f,spent:0b,utxoIndex:0Nj from 1#inputs;
  if[1=count inputs;:insert[`txInputs;coinbase]];
  inputs:1_update txinwitness:@[txinwitness;where 0h=type each txinwitness;{";" sv x}] from inputs;
  inputs:update txuid:(prevtxid,'string[n]) from inputs;
  inputs:inputs lj update spent:1b from utxo;
  inputs:update address:@[address;where 0h=type each address;raze/] from inputs;
  inputs:coinbase,:delete txuid from inputs;
  insert[`addressLookup;select address,height,partition:heightToPartition[index;chunkSize],tag:`$-3#'address from inputs where not address like ""];
  insert[`txInputs;inputs];
 }


updateUTXO:{[]
  -1(string .z.p)," Updating UTXO table";
  c:count utxo;
  spentTXIDS:exec utxoIndex from txInputs;
  delete from `utxo where i in spentTXIDS;
  -1(string .z.p)," Removed ",(string (c-(count utxo)))," spent transactions.";
  t:.z.p;
  update `u#txuid from `utxo;
  -1(string .z.p)," Recreating hash map : ",string (.z.p-t);
 }
