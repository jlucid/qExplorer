//Add support for multiple blocks-add additional param (1) to include transactions
.qexplorer.getBlock:{[block]
  partition:1+block div 1000;
  select from blocks where int=partition,height=block
 }

//Add support for multiple addresses
.qexplorer.addressLookup:{[addr]
 lookup:raze h(each;{0!select distinct height,first address by partition from addressLookup where int=convertToInt[x],tag=(`$-3#x),address like x};($[type[addr]=0h;addr;enlist addr]));
 inputs:raze {select int,height,txid,address,sum inputValue from txInputs where int=x[`partition],height in x[`height],address like x[`address]} each lookup;
 outputs:raze {select int,height,txid,address,sum outputValue from txOutputs where int=x[`partition],height in x[`height],address like x[`address]} each lookup;
 inputs uj outputs
 }

.qexplorer.txidLookup:{[tx]
 lookup:raze h(each;{0!select min height,min txid by partition from txidLookup where int=convertToInt[x],tag=(`$-3#x),txid like x};($[type[tx]=0h;tx;enlist tx]));
 txInfo:raze {select int,height,txid,size,weight from txInfo where int=x[`partition],height=x[`height],txid like x[`txid]} each lookup;
 inputs:raze {select int,height,txid,address,sum inputValue from txInputs where int=x[`partition],height=x[`height],txid like x[`txid]} each lookup;
 outputs:raze {select int,height,txid,address,sum outputValue from txOutputs  where int=x[`partition],height=x[`height],txid like x[`txid]} each lookup;
 `int`height`txid xdesc (txInfo lj `int`height`txid xkey inputs) uj outputs
 }

//Add txid param to find reward per txid
.qexplorer.minerReward:{[p]
 inputs:select first int,first height,sum inputValue by txid from txInputs where int in p;
 outputs:select first int,first height,sum outputValue by txid from txOutputs where int in p;
 tx:inputs lj outputs;
 coinbaseReward:select height,outputValue from tx where inputValue=0;
 txReward:select abs sum fee by height from update fee:(outputValue-inputValue) from tx where inputValue>0;
 update coinbaseReward:outputValue-fee from `height xasc coinbaseReward lj txReward
 }

//Sewit addresses where introduced in block 481824 (partition 481)
.qexplorer.segwitAddr:{[p]
 input:exec address from select distinct address from txInputs where int=p,not address like "";
 output:exec address from select distinct address from txOutputs where int=p,not address like "";
 allAddresses:distinct input,output;
 totalCount:count allAddresses;
 p2pkh:sum allAddresses like "1*";
 p2sh:sum allAddresses like "3*";
 bech32: sum allAddresses like "bc1*";
 insert[`segwitStats;([]height:enlist (p-1)*1000;totalUniqueAddr:enlist totalCount;p2pkh:enlist p2pkh;p2sh:enlist p2sh;bech32:enlist bech32)]
 }

.qexplorer.totalTx:{[p]
 select totalTx:sum tx,minTx:min tx,maxTx:max tx,avgTx:abs avg tx by int from blocks where int=p
 }

.qexplorer.avgTxSize:{[p]
 select blockSizeMB:avg (size%1000)%1000 by int from blocks where int=p
 }
