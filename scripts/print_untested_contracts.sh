# In case when you ended up with partially analyzed dataset
# Prints untested smart contract names

diff <(ls -1a $1 | sort)  <(ls -1a $2 | sort | sed -e 's/\.sol$//') \
    | grep "^>" | awk "{print \"$2/\" \$2 \".sol\"}"
