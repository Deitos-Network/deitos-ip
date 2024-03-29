FROM rust

LABEL description="Multistage Docker image for Substrate Node Template" \
  image.type="builder" \
  image.authors="you@email.com" \
  image.vendor="Substrate Developer Hub" \
  image.description="Multistage Docker image for Substrate Node Template" \
  image.source="https://github.com/substrate-developer-hub/substrate-node-template" \
  image.documentation="https://github.com/substrate-developer-hub/substrate-node-template"


RUN apt-get -qq update  \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq install --no-install-recommends \
      sudo \
      curl \
      wget \
      bash \
      coreutils \
      software-properties-common 

WORKDIR /node-template

RUN wget --no-check-certificate https://github.com/Deitos-Network/deitos-node/releases/download/v0.0.1/deitos-node  -O deitos-node
RUN chmod 755 deitos-node
RUN mv /node-template/deitos-node /usr/local/bin


RUN useradd -m -u 1000 -U -s /bin/sh -d /node-dev node-dev && \
  mkdir -p /chain-data /node-dev/.local/share && \
  chown -R node-dev:node-dev /chain-data && \
  ln -s /chain-data /node-dev/.local/share/deitos-node && \
  # unclutter and minimize the attack surface
  rm -rf /usr/bin /usr/sbin && \
  # check if executable works in this container
  /usr/local/bin/deitos-node --version 


USER node-dev

EXPOSE 30333 9933 9944 9615
VOLUME ["/chain-data"]

ENTRYPOINT ["/usr/local/bin/deitos-node", "--base-path", "/tmp/alice", "--chain", "local", "--alice", "--port", "30333", "--rpc-port", "9944", "--node-key", "0000000000000000000000000000000000000000000000000000000000000001", "--validator", "--force-authoring", "--unsafe-rpc-external", "--rpc-cors=all"]
