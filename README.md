## $TESTR ERC-20 Token

This is the ERC-20 token used in the https://github.com/Forte-Service-Company-Ltd/forte-demo-app project.

1. Clone this repository

```bash
git clone git@github.com:forte-service-company-ltd/testr-token # this needs to be created...
```

2. Install dependencies

```bash
npm install
```

3. Set up environment file

```bash
cp sample.env .env
```

## Notes about setting up the project

These steps are not necessary for most users. They are here to remind me about early processes for when they need to be updated, etc. This includes things like initial deployment of the token, setting up the pool, etc.

### Deploy the token

Inject modifiers into the testr token \_update function.

```bash
npx tsx index.ts injectModifiers policy.json src/RulesEngineIntegration.sol src/TestrToken.sol
```

Remove the `setCallingContractAdmin` function from `/src/RulesEngineIntegration.sol`

~~`function setCallingContractAdmin(address callingContractAdmin) external {}`~~

Deploy the token

```bash
source .env
forge script script/TestrToken.s.sol --broadcast --rpc-url $RPC_URL --private-key $PRIV_KEY --verify
```

Save the deployed contract address to the .env file

```env
TESTR_TOKEN=0xdeployedAddress
```

Mint some tokens from the deployed token contract

```bash
source .env
cast send $TESTR_TOKEN "mint(address,uint256)" $TOKEN_ADMIN $INITIAL_MINT_QTY --rpc-url $RPC_URL --private-key $PRIV_KEY

# mint some for vesting tests
cast send $TESTR_TOKEN "mint(address,uint256)" $TOKEN_ADMIN 1000000000000000000000 --rpc-url $RPC_URL --private-key $PRIV_KEY
```

Set the Rules Engine address in token contract

```bash
cast send $TESTR_TOKEN "setRulesEngineAddress(address)" $RULES_ENGINE_ADDRESS --rpc-url $RPC_URL --private-key $PRIV_KEY
# test that it worked
cast call $TESTR_TOKEN "rulesEngineAddress()(address)" --rpc-url $RPC_URL
```

Set the token contract admin

```bash
cast send $TESTR_TOKEN "setCallingContractAdmin(address)" $TOKEN_ADMIN --rpc-url $RPC_URL --private-key $PRIV_KEY
```

Register policy with rules engine and export obtained policy ID

```bash
npx tsx index.ts setupPolicy policy.json
```

```bash
export POLICY_ID=
```

```bash
npx tsx index.ts applyPolicy $POLICY_ID $TESTR_TOKEN
```

```bash
# test expected failure txs for ofac address
cast send $TESTR_TOKEN "transfer(address,uint256)" 0x8576acc5c05d6ce88f4e49bf65bdf0c62f91353c 10000 --rpc-url $RPC_URL --private-key $PRIV_KEY
cast send $TESTR_TOKEN "transferFrom(address,address,uint256)" $TOKEN_ADMIN 0x8576acc5c05d6ce88f4e49bf65bdf0c62f91353c 10000 --rpc-url $RPC_URL --private-key $PRIV_KEY

# test mint failure for TESTR test contract, no longer expected to fail
cast send $TESTR_TOKEN "mint(address,uint256)" $TOKEN_ADMIN 1000000000000000000000 --rpc-url $RPC_URL --private-key $PRIV_KEY

cast send $TESTR_TOKEN "mint(address,uint256)" 0xD46fAFEB018b24177f1C9b40369644619D0c0728 1000000000000000000000 --rpc-url $RPC_URL --private-key $PRIV_KEY

cast send $TESTR_TOKEN "mint(address,uint256)" 0x8d483143256D8b82949765c62D94A2e93f13B1BD 1000000000000000000000 --rpc-url $RPC_URL --private-key $PRIV_KEY

# unapply a policy
cast send $RULES_ENGINE_ADDRESS "unapplyPolicy(address,uint256[])" $TESTR_TOKEN "[62]" --rpc-url $RPC_URL --private-key $PRIV_KEY
# get policy Ids for the token
cast call $RULES_ENGINE_ADDRESS "getAppliedPolicyIds(address)(uint256[])" $TESTR_TOKEN --rpc-url $RPC_URL
# call adapter contract directly
cast call $ADAPTER_CONTRACT_ADDRESS "isDenied(address)(bool)" 0x8576acc5c05d6ce88f4e49bf65bdf0c62f91353c --rpc-url $RPC_URL

# get the rules for a policy (requires custom chagnes to index.ts)
npx tsx index.ts getAllRules $POLICY_ID

# direct call approve function
cast send $TESTR_TOKEN "approve(address,uint256)" 0xb89d1c5aE6A3d84496954dcB8035eaD42Ab8aFeC 120000000 --rpc-url $RPC_URL --private-key $PRIV_KEY

# reduce approved spend for pool to zero
cast send $TESTR_TOKEN "approve(address,uint256)" 0x3a625e46759e46831cbf1b91765dc418f7988df8 1000 --rpc-url $RPC_URL --private-key $PRIV_KEY

# get balance
cast call $TESTR_TOKEN "balanceOf(address)(uint256)" 0xE4F53F8aD1EB9B8A556ccF363a2389D59447a6df --rpc-url $RPC_URL
cast call $TESTR_TOKEN "balanceOf(address)(uint256)" 0xD46fAFEB018b24177f1C9b40369644619D0c0728 --rpc-url $RPC_URL
cast call $TESTR_TOKEN "balanceOf(address)(uint256)" 0x8d483143256D8b82949765c62D94A2e93f13B1BD --rpc-url $RPC_URL

550000000000000000000
350000000000000000000
500000000000000000000
50000000000000000000
2892842748003511197807
1000000000000000000000
250000000000000000000

650000000000000000000
950000000000000000000
999999999999999999990

# transfer 50 tokens (250 should be avail to transfer)
cast send $TESTR_TOKEN "transfer(address,uint256)" 0x8d483143256D8b82949765c62D94A2e93f13B1BD 250000000000000000000 --rpc-url $RPC_URL --private-key $PRIV_KEY

# attempt transfer from 0xD4 account, this should fail
cast send $TESTR_TOKEN "transfer(address,uint256)" 0x8d483143256D8b82949765c62D94A2e93f13B1BD 50000000000000000000 --rpc-url $RPC_URL --private-key $DEV_PRIV_KEY

cast send $TESTR_TOKEN "transfer(address,uint256)" 0x8d483143256D8b82949765c62D94A2e93f13B1BD 1000000000000000000000 --rpc-url $RPC_URL --private-key $DEV3_PRIV_KEY


# direct call transferFrom
cast send $TESTR_TOKEN "transferFrom(address,address,uint256)" 0xE4F53F8aD1EB9B8A556ccF363a2389D59447a6df 0xb89d1c5aE6A3d84496954dcB8035eaD42Ab8aFeC 120000000 $TOKEN_ADMIN --rpc-url $RPC_URL --private-key $PRIV_KEY

# test transferFrom to the pool, this should work
cast send $TESTR_TOKEN "transferFrom(address,address,uint256)" 0xE4F53F8aD1EB9B8A556ccF363a2389D59447a6df 0x3a625e46759e46831cbf1b91765dc418f7988df8 120000000 $TOKEN_ADMIN --rpc-url $RPC_URL --private-key $PRIV_KEY

# test swap from TSTR to USDC
cast send $POOL_ADDRESS "swap(address,uint256,uint256,address,uint256)(uint256,uint256,uint256)" $TESTR_TOKEN 100000000000000000000 1 $TOKEN_ADMIN 1770000000 --rpc-url $RPC_URL --private-key $PRIV_KEY
```

## Create the AMM

This is done from the liquidity-altbc repo. Set the XTOKEN_ADDRESS env variable to the address of the deployed testr token.
Also need to set the y token address which is a mock USDC coin. The address on sepolia for the usdc token we are using is: `0xa3CA2354B631F3a3aEBCE4cc5503f67D14A18423`

Then run this script:

```bash
forge script script/deploy/deploy.s.sol:ALTBCPoolDeployment --ffi --broadcast --rpc-url $RPC_URL --gas-price $GAS_NUMBER
```
