#!/usr/bin/env bash

echo Hello from entrypoint
echo $@

cd /go/src/ilf

rm -rf example/crowdsale/build
rm example/crowdsale/contracts/crowdsale.sol
rm example/crowdsale/contracts/Migrations.sol
rm example/crowdsale/transactions.json
rm example/crowdsale/migrations/2_deploy_contracts.js
cp "$1" example/crowdsale/contracts/

compiler_version_and_contracts=$(node printContractNames.js $1)
solc_version=$(echo $compiler_version_and_contracts | cut -d " " -f 1)
contracts=$(echo $compiler_version_and_contracts | cut -d " " -f 2-)
node versionedMigrations.js $solc_version >> /go/src/ilf/example/crowdsale/contracts/Migrations.sol

echo $contracts

solc-select install $solc_version
solc-select use $solc_version

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

python3 /go/src/ilf/script/extract.py --proj /go/src/ilf/example/crowdsale/ --port 8545
cat example/crowdsale/transactions.json


i=0
rm -rf /results.json /new_results.json /old_results.json
touch /results.json
for c in $contracts; do
    echo Contract: $c
    python3 -m ilf --limit 100 --model ./model/ --fuzzer imitation --proj ./example/crowdsale/ --contract $c --log_to_file results.txt -v 1
    tail -1 results.txt | awk '{$1=""; $2=""; print $0}' | jq '(keys_unsorted[]) as $key | if $key!="tx_count" and $key!="num_contracts" and $key!="insn_coverage" and $key!="block_coverage"  then {($key): .[$key]} else empty end' > /new_results.json
    if [ $i -gt 0 ]; then
        cp /results.json /old_results.json
        jq -s '.[0] * .[1]' /old_results.json /new_results.json > /results.json
    else
        cp /new_results.json /results.json
    fi
    ((i=i+1))
done