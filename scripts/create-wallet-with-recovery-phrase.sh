#!/bin/bash


# For mainnet
#NET="mainnet"
#NET_WITH_MAGIC="--mainnet"
# For testnet
NET="testnet"
NET_WITH_MAGIC="--testnet-magic 1097911063"

### Extract root keys and create Payment and Stake Addresses using cardano-address tool ###

# Recover existing wallet
#echo "your wallet 24 words" > phrase.prv
# or create a new wallet
cardano-address recovery-phrase generate > phrase.prv
chmod 400 phrase.prv

cat phrase.prv | cardano-address key from-recovery-phrase Shelley > rootkey.prv
chmod 400 rootkey.prv
#cat rootkey.prv | cardano-address key public --with-chain-code > rootkey.pub

cat rootkey.prv | cardano-address key child 1852H/1815H/0H/2/0 > stake.prv
#cat stake.prv | cardano-address key public --with-chain-code | cardano-address address stake --network-tag ${NET} > stake.addr

### Create Payment and Stake vkey/skey files using cardano-cli ###

cardano-cli key convert-cardano-address-key --signing-key-file stake.prv --shelley-stake-key --out-file stake.skey
cardano-cli key verification-key --signing-key-file stake.skey --verification-key-file Ext_ShelleyStake.vkey
cardano-cli key non-extended-key --extended-verification-key-file Ext_ShelleyStake.vkey --verification-key-file stake.vkey
cardano-cli stake-address build --stake-verification-key-file stake.vkey --out-file stake.addr ${NET_WITH_MAGIC}
rm Ext_ShelleyStake.vkey stake.prv


for NR in {0..5}
do

cat rootkey.prv | cardano-address key child 1852H/1815H/0H/0/${NR} > addr-${NR}.prv
#cat addr-${NR}.prv | cardano-address key public --with-chain-code | cardano-address address payment --network-tag ${NET} > payment-short-${NR}.addr
cardano-cli key convert-cardano-address-key --signing-key-file addr-${NR}.prv --shelley-payment-key --out-file payment-${NR}.skey
cardano-cli key verification-key --signing-key-file payment-${NR}.skey --verification-key-file Ext_ShelleyPayment-${NR}.vkey
cardano-cli key non-extended-key --extended-verification-key-file Ext_ShelleyPayment-${NR}.vkey --verification-key-file payment-${NR}.vkey
cardano-cli address build --payment-verification-key-file payment-${NR}.vkey  --stake-verification-key-file stake.vkey --out-file payment-${NR}.addr ${NET_WITH_MAGIC}
rm Ext_ShelleyPayment-${NR}.vkey addr-${NR}.prv

done

