#!/usr/bin/env bash

###############################################################################
# run.sh is executed on the host and is used to start the Docker Compose
# service.
###############################################################################

# set path to Docker Registry
DOCKER_REGISTRY='/docker-registry'

# start Docker Daemon
service docker start

# create required directories
mkdir -p $DOCKER_REGISTRY/auth $DOCKER_REGISTRY/data

# create certificate pair
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -sha256 \
  -keyout $DOCKER_REGISTRY/auth/domain.key \
  -out $DOCKER_REGISTRY/auth/domain.crt \
  -subj "/C=US/ST=Iowa/L=Ames/O=Nickolas Kraus/CN=*.compute-1.amazonaws.com"

# update trusted certificate store
cp $DOCKER_REGISTRY/auth/domain.crt /etc/pki/ca-trust/source/anchors/domain.crt
update-ca-trust
service docker restart

# start Docker Registry service
docker-compose \
  -f $DOCKER_REGISTRY/docker-compose.yml \
  -p docker-registry \
  up
