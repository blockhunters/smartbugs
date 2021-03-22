#!/usr/bin/env bash

if [ ! -d "ilf" ]; then
	git clone https://github.com/eth-sri/ilf.git || exit 1
fi
docker build -t smarbugs/ilf .

