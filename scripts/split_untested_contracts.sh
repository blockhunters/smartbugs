# In case when you ended up with partially analyzed dataset
# Copies contracts not present in results dir and splits untested contract's dataset evenly into n parts

# $1 results dir for a particular tool run eg. results/ilf/20211704_0853/
# $2 dataset dir containing .sol files
# $3 output dir
# $4 The dataset will be split into $4 parts
bash ./scripts/print_untested_contracts.sh $1 $2 $3 | python ./scripts/split_contracts.py $3 $4
