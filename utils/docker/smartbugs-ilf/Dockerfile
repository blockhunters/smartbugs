FROM ilf
RUN apt-get install -y python3.8 jq

COPY scripts /workdir/scripts

RUN npm install -g npm typescript
COPY solidity_ast/* ./
RUN npm install
RUN tsc versionedMigrations.ts
RUN tsc printContractNames.ts
