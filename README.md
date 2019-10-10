## CLO to EOS token swap

The repo preserves smart-contract codes that were used to establish a EOS <--> CLO swap channel by Callisto Team.

My swapping method involves "pegged token" creation at EOS mainnet. We allow any CLO owner to swap his(her) CLO from Callisto mainnet to EOS token and back to CLO at any time. 

The provided contracts are reusable and anyone can establish a swap channel between EOS and any Ethereum-compatible chain including Ethereum, Ethereum CLassic, UBQ, Expanse and others.

### (!) Disclaimer: This is the very first implementation of the contracts. It is not advised to use it with large quantities of funds at this stage. The contract will undergo a security audit in future and it is strongly advised to wait for the results before using it with large quantities of funds.

## Currently deployed contracts

- CLEOS token at EOS mainnet: [callistotokn](https://bloks.io/account/callistotokn)

- CLO <-> EOS swap contract at Callisto mainnet: [0xfb03d543afd48934414e50cf5bc5bb990aa3ce04](https://explorer2.callisto.network/addr/0xfb03d543afd48934414e50cf5bc5bb990aa3ce04)

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

I need to swap 500 CLO from my CLO mainnet address ( `0x01000b5fe61411c466b70631d7ff070187179bbf` ) to my EOS account ( `dexaraniiznx` ).

The first thing I need to do is to link my EOS account to the CLO address at EOS token contract. There is a special function [linktoeth](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/blob/a5e1d236ec8ba11353c951b46dddbafcb03156db/eos/include/token.hpp#L38) that needs to be executed to link the accounts.

I have succesfully executed the `linktoeth` function: https://bloks.io/transaction/418a92a1a454bda7b431d5b51ed2077dcc7caa1590e0267c519029ddf0c6fdc5

The function accepts two arguments: `acc` - the name of EOS account and `eth_acc` - the hex address at Ethereum-based chain (in my case its CLO chain, however we can use the same address at multiple Ethereum chains).

I've called the function with the following arguments:

- linktoeth( dexaraniiznx, 0x01000b5fe61411c466b70631d7ff070187179bbf )

Then I need to confirm this linking of accounts at CLO contract. I need to call the [link](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/blob/a5e1d236ec8ba11353c951b46dddbafcb03156db/eth/eth_to_eos_swapper.sol#L41-L54) function of the CLO contract to do so. The function accepts EOS account name as a parameter. In this step it is important that I've called the function from my CLO address that matches the linked address at EOS contract.

I've called the function with the following arguments:

- link( dexaraniiznx )

The funciton is executed succesfully: https://explorer2.callisto.network/tx/0xb3d5281ca601b161dad95ed45b1874eb48395d52f92dab2c466049cf9365e08d

Now I need to request the swap via the [request_swap](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/blob/a5e1d236ec8ba11353c951b46dddbafcb03156db/eth/eth_to_eos_swapper.sol#L56-L64) function of the CLO swap contract. The function accepts two arguments: `eos_address` - EOS account name which must match the linked EOS account in both CLO contract and EOS token contract; `data` - this is an optional parameter that is intended to preserve some metadata. It is important that I need to send CLO alongside the `request_swap` function call. Thus, the amount of CLO deposited into the contract will be frozen, and the linked account will receive the same amount of CLEOS tokens in exchange.


I've called the `request_swap` function with the following arguments:

- request_swap( dexaraniiznx, "" )

- 500 CLO were sent with the transaction

The function call at CLO mainnet: https://explorer2.callisto.network/tx/0xdd18a640c8c959ed236e6d2c1f8bc20808fb5355162e0d501c6ade2ab7d6cee1

Then the Callisto Relay will execute the swap. Callisto Relay should check all account links at CLO contract. Whenever it faces an account link with positive pending swap tokens Callisto Relay should check if there is a matching link in EOS token contract. If the matching link exists then Callisto Relay will freeze the CLO at swap contract and mint the CLEOS tokens at EOS chain via the [issue](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/blob/master/eos/include/token.hpp#L76) function. NOTE: `memo` of the EOS issue transaction should match the `data` of the account link in CLO contract.

Callisto Relay will be provided by Callisto team in the near future once the contracts are tested and ready for mass use. Currently the crosschain swaps are handled manually.


Callisto Relay confirms the swap with the transaction: https://explorer2.callisto.network/tx/0xbd663a0c2d30d7ba9affe45de74201ea4bf8389e454977778f0bbd3e8fbeac4f

[process_swap_to_eos](https://github.com/EthereumCommonwealth/Eth-To-Eos-swap/blob/a5e1d236ec8ba11353c951b46dddbafcb03156db/eth/eth_to_eos_swapper.sol#L85-L94) function is used to confirm the swap if the provided linked addresses match linked addresses at EOS token contract.

Then Callisto Relay should mint the CLEOS token. Here is the minting transaction: https://bloks.io/transaction/7dc5cf0df79977bcf3e5458e2570928705597ca9d292cf2f5f4c9f678628aebd

Once the tokens are minted the Callisto Relay must send them to the account which is linked to the swap requesters address at CLO chain.  `memo` of the transaction must match the `data` of the swap request. In my case the `dexaraniiznx` account is linked to my `0x01000b5fe61411c466b70631d7ff070187179bbf` address, so the Callisto Relay should send the tokens to the `dexaraniiznx` account.

The transaction is executed succesfully at EOS mainnet:
https://bloks.io/transaction/2bedadb939e1fd4dfdea8c93d6383451be89a048c1fb5f76a6c62d87e94c5b6d



As the result, I have my CLO tokens (CLEOS) at the EOS mainnet: 

![CLEOS_tokens](https://user-images.githubusercontent.com/26142412/66598155-ed900480-eb8f-11e9-8f07-a6c3ec8c275f.png)
