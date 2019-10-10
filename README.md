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
