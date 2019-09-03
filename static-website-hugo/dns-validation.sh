#!/usr/bin/env bash

usage() {
  echo "usage: dns-validation.sh <domain-name> <stack-name>"
}

domain_name="$1"
stack_name="$2"

if [ -z "$domain_name" ]; then
  usage
  echo -en "\033[0;31m" # display red
  echo "Error: Provide a domain name."
  echo -en "\033[0m"
  exit 1
fi

if [ -z "$stack_name" ]; then
  usage
  echo -en "\033[0;31m" # display red
  echo "Error: Provide a stack name."
  echo -en "\033[0m"
  exit 1
fi

output=$(aws cloudformation describe-stack-events \
--stack-name $stack_name \
--query 'StackEvents[?ResourceStatusReason != `null`] | [?contains(ResourceStatusReason, `Content`) == `true`].ResourceStatusReason' \
| grep -o -E "{.*}")

name=$(echo $output | perl -n -e '/Name: (.*?),/ && print $1')

value=$(echo $output | perl -n -e '/Value: (.*?)}/ && print $1')

hosted_zone_id=$(aws route53 list-hosted-zones \
--query "HostedZones[?Name==\`$domain_name.\`].Id" \
| grep -o -E "[A-Z0-9]+")

cat > dns-validation.json <<EOL
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "$name",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$value"
          }
        ]
      }
    }
  ]
}
EOL

aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch file://dns-validation.json

rm dns-validation.json
