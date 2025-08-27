## $KRYPT ERC-20 Token

1. Clone this repository

```bash
git clone git@github.com:thrackle-io/this-repo
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

Inject modifiers into the krypt token \_update function.

```bash
npx tsx index.ts injectModifiers policy.json src/RulesEngineIntegration.sol src/KryptToken.sol
```

Remove the `setCallingContractAdmin` function from `/src/RulesEngineIntegration.sol`

~~`function setCallingContractAdmin(address callingContractAdmin) external {}`~~

Deploy the token

```bash
source .env
forge script script/KryptToken.s.sol --broadcast --rpc-url $RPC_URL --private-key $PRIV_KEY --verify
```

Save the deployed contract address to the .env file

```env
KRYPT_TOKEN=0xdeployedAddress
```

Mint some tokens from the deployed token contract

```bash
source .env
cast send $KRYPT_TOKEN "mint(address,uint256)" $TOKEN_ADMIN $INITIAL_MINT_QTY --rpc-url $RPC_URL --private-key $PRIV_KEY
```

Set the Rules Engine address in token contract

```bash
cast send $KRYPT_TOKEN "setRulesEngineAddress(address)" $RULES_ENGINE_ADDRESS --rpc-url $RPC_URL --private-key $PRIV_KEY
# test that it worked
cast call $KRYPT_TOKEN "rulesEngineAddress()(address)" --rpc-url $RPC_URL
```

Set the token contract admin

```bash
cast send $KRYPT_TOKEN "setCallingContractAdmin(address)" $TOKEN_ADMIN --rpc-url $RPC_URL --private-key $PRIV_KEY
```

Register policy with rules engine and export obtained policy ID

```bash
npx tsx index.ts setupPolicy policy.json
```

```bash
export POLICY_ID=
```

```bash
npx tsx index.ts applyPolicy $POLICY_ID $KRYPT_TOKEN
```

Test failure condition by trying to transfer tokens to an address on the OFAC sanctions list

```bash
cast send $KRYPT_TOKEN "transfer(address,uint256)" 0x8576acc5c05d6ce88f4e49bf65bdf0c62f91353c 10000 --rpc-url $RPC_URL --private-key $PRIV_KEY
cast send $KRYPT_TOKEN "transferFrom(address,address,uint256)" $TOKEN_ADMIN 0x8576acc5c05d6ce88f4e49bf65bdf0c62f91353c 10000 --rpc-url $RPC_URL --private-key $PRIV_KEY

# test mint failure for KRYPT test contract
cast send $KRYPT_TOKEN "mint(address,uint256)" $TOKEN_ADMIN 1000000 --rpc-url $RPC_URL --private-key $PRIV_KEY

# unapply a policy
cast send $RULES_ENGINE_ADDRESS "unapplyPolicy(address,uint256[])" $KRYPT_TOKEN "[10]" --rpc-url $RPC_URL --private-key $PRIV_KEY

cast call $RULES_ENGINE_ADDRESS "getAppliedPolicyIds(address)(uint256[])" $KRYPT_TOKEN --rpc-url $RPC_URL

cast call $ADAPTER_CONTRACT_ADDRESS "isDenied(address)(bool)" 0x8576acc5c05d6ce88f4e49bf65bdf0c62f91353c --rpc-url $RPC_URL

# get the rules for a policy (requires custom chagnes to index.ts)
npx tsx index.ts getAllRules $POLICY_ID
```
