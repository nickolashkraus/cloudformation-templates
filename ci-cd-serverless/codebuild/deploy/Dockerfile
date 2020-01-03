FROM openjdk:jdk

ARG NVM_VERSION=v0.34.0

RUN yum -y update && yum upgrade

RUN yum -y install \
      curl \
      git \
      jq \
      make \
			python3 \
			unzip

# install nvm
RUN export NVM_DIR="$HOME/.nvm" && ( \
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"; \
    cd "$NVM_DIR"; \
    git checkout `git describe --abbrev=0 --tags --match "${NVM_VERSION}" $(git rev-list --tags --max-count=1)`; \
    ) && \. "$NVM_DIR/nvm.sh"

# install node
# /root/.nvm/versions/node/<version>/bin is prepended to PATH
RUN export NVM_DIR="$HOME/.nvm" && \
      \. "$NVM_DIR/nvm.sh" && \
      nvm install node

# install Serverless Framework
RUN export NVM_DIR="$HOME/.nvm" && \
      \. "$NVM_DIR/nvm.sh" && \
      npm install -g serverless

# install the AWS CLI using the bundled installer
RUN curl 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip' \
      -o 'awscli-bundle.zip' && \
      unzip awscli-bundle.zip && \
      python3 ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# update .bashrc
RUN command printf '# set nvm source directory and load nvm\n' >> $HOME/.bashrc
RUN command printf 'export NVM_DIR="$HOME/.nvm"\n' >> $HOME/.bashrc
RUN command printf '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"\n' >> $HOME/.bashrc

ENTRYPOINT ["/bin/bash"]
