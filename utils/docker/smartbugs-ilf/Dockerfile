FROM ilf
RUN apt-get install -y python3.8 jq

RUN python3 -m pip --no-cache-dir install --upgrade setuptools pip
RUN LC_ALL=C.UTF-8 python3 -m pip install solidity_parser

COPY scripts /workdir/scripts
