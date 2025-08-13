# LAMP Stack with ASG

## Prerequisites

- Create an EC2 Key Pair:

```bash
./lamp-asg/create-key-pair.sh <key-name>
```

**Note**: Your private key file must be protected from read and write operations from any other users. If your private key can be read or written to by anyone but you, then SSH ignores your key. For this reason, the private key is given `400` permissions.

The key name should also be updated in `lamp-asg/parameters.json` or `lamp-asg/parameters.properties`.

- Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

## Validation

```bash
aws cloudformation validate-template \
--template-body file://lamp-asg/template.yaml
```

## Deployment

```bash
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://lamp-asg/template.yaml \
--parameters file://lamp-asg/parameters.json
```

Alternatively, using `deploy`:

```bash
aws cloudformation deploy \
--stack-name $STACK_NAME \
--template-file lamp-asg/template.yaml \
--parameter-overrides $(cat lamp-asg/parameters.properties)
```

## Testing

- Testing SSH:

```bash
ASG_ID=$(aws cloudformation describe-stacks \
--stack-name $STACK_NAME \
--query 'Stacks[0].Outputs[?OutputKey==`ASGId`].OutputValue' \
| grep -o -E "[a-zA-Z0-9\.\-]+")
```

```bash
EC2_INSTANCES=($(aws autoscaling describe-auto-scaling-groups \
--auto-scaling-group-names $ASG_ID \
--query 'AutoScalingGroups[0].Instances[*].InstanceId' \
| grep -o -E "[a-zA-Z0-9\.\-]+"))
```

```
EC2_PUBLIC_DNS=()
for i in $EC2_INSTANCES; do
  EC2_PUBLIC_DNS+=($(aws ec2 describe-instances \
  --instance-ids $i \
  --query 'Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicDnsName' \
  | grep -o -E "[a-zA-Z0-9\.\-]+"))
done
```

```bash
ssh -i lamp-asg/lamp-asg.pem ec2-user@$EC2_PUBLIC_DNS[1]
```

```bash
ssh -i lamp-asg/lamp-asg.pem ec2-user@$EC2_PUBLIC_DNS[2]
```

```bash
ssh -i lamp-asg/lamp-asg.pem ec2-user@$EC2_PUBLIC_DNS[...]
```

**Note**: To become root, execute `sudo -i`.

- Testing web server:

```bash
ALB_PUBLIC_DNS=$(aws cloudformation describe-stacks \
--stack-name $STACK_NAME \
--query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
| grep -o -E "[a-zA-Z0-9\:\/\.\-]+")
```

```bash
http -v $ALB_PUBLIC_DNS
```
