#!/usr/bin/env bash

usage() {
  echo "usage: create-key-pair.sh <key-name>"
}

key_name="$1"

if [ -z "$key_name" ]; then
  usage
  echo -en "\033[0;31m" # display red
  echo "Error: Provide a key name."
  echo -en "\033[0m"
  exit 1
fi

aws ec2 create-key-pair --key-name $key_name --query 'KeyMaterial' --output text > $key_name.pem

chmod 400 $key_name.pem
