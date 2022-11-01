FROM rust:latest as solana

WORKDIR /home/

# Install Solana

RUN sh -c "$(curl -sSfL https://release.solana.com/v1.14.7/install)"

ENV PATH="/root/.local/share/solana/install/active_release/bin:$PATH"

# Install Anchor

FROM solana as anchor

RUN RUST_BACKTRACE=full cargo install --git https://github.com/project-serum/anchor avm --locked --force
RUN avm install latest
RUN avm use latest


FROM anchor as anchor-node
RUN mkdir /usr/local/nvm
# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 18.12.0

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

# replace shell with bash so we can use source
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# install node, npm and yarn using nvm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install -g yarn


# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN node -v
RUN npm -v
