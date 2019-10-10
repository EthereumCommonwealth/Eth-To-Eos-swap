## CLO to EOS token swap

The repo preserves smart-contract codes that were used to establish a EOS <--> CLO swap channel by Callisto Team.

My swapping method involves "pegged token" creation at EOS mainnet. We allow any CLO owner to swap his(her) CLO from Callisto mainnet to EOS token and back to CLO at any time. 

The provided contracts are reusable and anyone can establish a swap channel between EOS and any Ethereum-compatible chain including Ethereum, Ethereum CLassic, UBQ, Expanse and others.

## Swapping contracts structure

The "CLO to EOS swap channel" consists of two parts: CLO smart-contract and a token on EOS mainnet. We allow users to freeze their CLO at Callisto mainnet and get the corresponding amount of tokens at EOS mainnet in exchange. A user can swap EOS tokens back to CLO at any time.  With the current implementation of the swap channel, no fee will be charged.

To avoid name mismatch and confusion, the name of the token is `CLEOS` while the name of the coin at Callisto mainnet is `CLO`.

The source code of the token with the implementation of swapping functions can be found [here](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/tree/master/eos).

The source code of the swap channel at Callisto (or Ethereum) mainnet can be found [here](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/tree/master/eth).

## Swapping algorithm

To proceed with a swap, a user must:

1. Create an address at EOS mainnet. A user can follow [this guide](https://medium.com/@dexaran820/creating-and-signing-up-eos-account-sending-receiving-transactions-14157b97c6e2) to sign up EOS account but it is not free. [Wombat wallet](https://www.getwombat.io/) allows to get the EOS account for free.

2. Link EOS account name to CLO address at the EOS contract.

3. Link EOS account name to CLO address at the CLO contract. It is very important that the links between EOS and CLO accounts match in both contracts. This is the only way to make sure that user does understand what he is doing and he owns both of the  accounts at the two different chains.

4. Submit the swap request.

5. Wait for CLO team to execute the swap.

## Example

I need to swap 1000 CLO from my CLO mainnet address ( `0x01000b5fe61411c466b70631d7ff070187179bbf` ) to my EOS account ( `dexaraniiznx` ).

The first thing I need to do is to link my EOS account to the CLO address at EOS token contract. There is a special function [linktoeth](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/blob/a5e1d236ec8ba11353c951b46dddbafcb03156db/eos/include/token.hpp#L38) that needs to be executed to link the accounts.

I have succesfully executed the `linktoeth` function: https://bloks.io/transaction/418a92a1a454bda7b431d5b51ed2077dcc7caa1590e0267c519029ddf0c6fdc5

The function accepts two arguments: `acc` - the name of EOS account and `eth_acc` - the hex address at Ethereum-based chain (in my case its CLO chain, however we can use the same address at multiple Ethereum chains).

I've called the function with the following arguments:

- linktoeth( dexaraniiznx, 0x01000b5fe61411c466b70631d7ff070187179bbf )

Then I need to confirm this linking of accounts at CLO contract. I need to call the [link](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/blob/a5e1d236ec8ba11353c951b46dddbafcb03156db/eth/eth_to_eos_swapper.sol#L41-L54) function of the CLO contract to do so. The function accepts EOS account name as a parameter. In this step it is important that I've called the function from my CLO address that matches the linked address at EOS contract.

I've called the function with the following arguments:

- link( dexaraniiznx )

The funciton is executed succesfully: https://explorer2.callisto.network/tx/0xb3d5281ca601b161dad95ed45b1874eb48395d52f92dab2c466049cf9365e08d

Now I need to request the swap via the [request_swap](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/blob/a5e1d236ec8ba11353c951b46dddbafcb03156db/eth/eth_to_eos_swapper.sol#L56-L64) function of the CLO swap contract. The function accepts two arguments: `eos_address` - EOS account name which must match the linked EOS account in both CLO contract and EOS token contract; `data` - this is an optional parameter that is intended to preserve some metadata.
