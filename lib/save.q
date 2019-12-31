// Function used to store block data into the blocks schema
// For the first block, 0, we need to add a value for previousblockhash because its not present
// We remove the tx info before inserting
saveBlockInfo:{[Block]
  if[0f~index;Block[`result],:(!) . enlist@'(`previousblockhash;"NULL")];
  block:update tx:count tx,height:"j"$height,version:"j"$version,time:"P"$string time,mediantime:"P"$string mediantime from Block[`result];
  insert[`blocks;delete nTx,nextblockhash from block]
 }

//Fuction used to get the raw transactional for that block
saveTransactionInfo:{[Block]
  Height:Block[`result][`height];
  tx:delete version from update vin:count each vin,vout:count each vout from (`height xcols update height:"j"$Height from Block[`result][`tx]);
  insert[`txidLookup;select txid,height from tx];
  insert[`txInfo;tx]
 }

//Function to retreive all outputs for the block. Requires getBlock with valance set to 2.
saveTransactionOutputs:{[Block]
  Height:Block[`result][`height];
  outputs:(`height xcols select height:"j"$Height,txid,vout from Block[`result][`tx]);
  outputs:update n:"i"$vout[;`n],scriptPubKey:vout[;`scriptPubKey],outputValue:vout[;`value],address:vout[;`scriptPubKey;`addresses] from ungroupCol[outputs;`vout];
  outputs:update scriptPubKey:-8!'scriptPubKey from outputs;
  outputs:update address:@[address;where 0h=type each address;raze] from outputs;
  outputs:select height,txid,outputValue,address,n,scriptPubKey from outputs;
  insert[`txOutputs;outputs];
  insert[`addressLookup;select address,height from outputs where not address like ""]
 }

//Function to retrive all the inputs for each transaction
saveTransactionInputs:{[Block]
  Height:Block[`result][`height];
  inputs:(`height xcols update height:"j"$Height from Block[`result][`tx]);
  inputs:select height,txid,prevtxid:vin[;`txid],n:`int$vin[;`vout],scriptSig:-8!'vin[;`scriptSig],sequence:vin[;`sequence],txinwitness:vin[;`txinwitness] from ungroupCol[inputs;`vin];
  coinbase:update n:0i,address:enlist "",inputValue:0f,spent:0b from 1#inputs;
  if[1=count inputs;:insert[`txInputs;coinbase]];
  inputs:update txuid:(prevtxid,'string[n]) from inputs;
  inputs:1_update txinwitness:@[txinwitness;where 0h=type each txinwitness;{";" sv x}] from inputs;
  inputs:coinbase,:delete txuid from inputs;
  insert[`txInputs;inputs]
 }
