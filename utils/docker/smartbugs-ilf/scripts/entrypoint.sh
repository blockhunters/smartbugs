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
rm -rf /results.json /new_results.json /old_results.json
touch /results.json
for c in $contracts; do
    echo Contract: $c
    python3 -m ilf --proj ./example/crowdsale/ --contract $c --fuzzer imitation --model ./model/ --limit 2000 --log_to_file results.txt -v 1
    tail -1 results.txt | awk '{$1=""; $2=""; print $0}' | jq '(keys_unsorted[]) as $key | if $key!="tx_count" and $key!="num_contracts" and $key!="insn_coverage" and $key!="block_coverage"  then {($key): .[$key]} else empty end' > /new_results.json
    if [ $i -gt 0 ]; then
        cp /results.json /old_results.json
        jq -s '.[0] * .[1]' /old_results.json /new_results.json > /results.json
    else
        cp /new_results.json /results.json
    fi
    ((i=i+1))
done