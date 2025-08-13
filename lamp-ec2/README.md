# LAMP Stack with EC2

## Prerequisites

- Create an EC2 Key Pair:

```bash
./lamp-ec2/create-key-pair.sh <key-name>
```

**Note**: Your private key file must be protected from read and write operations from any other users. If your private key can be read or written to by anyone but you, then SSH ignores your key. For this reason, the private key is given `400` permissions.

The key name should also be updated in `lamp-ec2/parameters.json` or `lamp-ec2/parameters.properties`.

- Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

## Validation

```bash
aws cloudformation validate-template \
--template-body file://lamp-ec2/template.yaml
```

## Deployment

```bash
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://lamp-ec2/template.yaml \
--parameters file://lamp-ec2/parameters.json
```

Alternatively, using `deploy`:

```bash
aws cloudformation deploy \
--stack-name $STACK_NAME \
--template-file lamp-ec2/template.yaml \
--parameter-overrides $(cat lamp-ec2/parameters.properties)
```

## Testing

- Testing SSH:

```bash
EC2_PUBLIC_DNS=$(aws cloudformation describe-stacks \
--stack-name $STACK_NAME \
--query 'Stacks[0].Outputs[?OutputKey==`EC2PublicDns`].OutputValue' \
| grep -o -E "[a-zA-Z0-9\.\-]+")
```

```bash
ssh -i lamp-ec2/lamp-ec2.pem ec2-user@$EC2_PUBLIC_DNS
```

**Note**: To become root, execute `sudo -i`.

- Testing web server:

```bash
http -v http://$EC2_PUBLIC_DNS
```
