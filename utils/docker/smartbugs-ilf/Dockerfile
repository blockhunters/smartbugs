FROM ilf
RUN apt-get install -y python3.8 jq
RUN python3.8 -m pip --no-cache-dir install --upgrade setuptools pip
RUN python3.8 -m pip install solidity_parser

COPY scripts /workdir/scripts

