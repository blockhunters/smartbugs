#!/usr/bin/env bash

echo Hello from entrypoint
echo $@

cd /go/src/ilf

rm -rf example/crowdsale/build
rm example/crowdsale/contracts/crowdsale.sol
rm example/crowdsale/transactions.json
rm example/crowdsale/migrations/2_deploy_contracts.js
cp "$1" example/crowdsale/contracts/

contracts=$(python3.8 /workdir/scripts/printContractNames.py "$1" | grep -v ANTLR)
echo $contracts

i=0
for c in $contracts; do
    echo "var c${i} = artifacts.require(\"${c}\");" >> example/crowdsale/migrations/2_deploy_contracts.js
    ((i=i+1))
done
echo "module.exports = function(deployer) {" >> example/crowdsale/migrations/2_deploy_contracts.js
i=0
for c in $contracts; do
    echo "deployer.deploy(c${i});" >> example/crowdsale/migrations/2_deploy_contracts.js
    ((i=i+1))
done
echo "};" >> example/crowdsale/migrations/2_deploy_contracts.js
echo >> example/crowdsale/migrations/2_deploy_contracts.js

cat example/crowdsale/migrations/2_deploy_contracts.js

python3 script/extract.py --proj example/crowdsale/ --port 8545
cat example/crowdsale/transactions.json


i=0
mkdir -p /dataset/train_data
for c in $contracts; do
    echo Contract: $c
    python3 -m ilf --proj ./example/crowdsale/ --contract $c --limit 2000 --fuzzer symbolic --dataset_dump_path /dataset/train_data/$c.data
    ((i=i+1))
done