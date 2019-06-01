# cloudformation-templates

A collection of CloudFormation templates.

## AWS API Gateway with a Mock Integration

### Validation

```bash
aws cloudformation validate-template \
--template-body file://api-gateway-mock-integration/template.yaml
```

### Deployment

```bash
aws cloudformation deploy \
--stack-name mock-api \
--template-file api-gateway-mock-integration/template.yaml
```

### Testing

```bash
API_GATEWAY_ID=$(aws apigateway get-rest-apis --query 'items[?name==`mock-api`].id' | grep -o -E "[a-z0-9]+")
```

```bash
http -v POST \
https://$API_GATEWAY_ID.execute-api.us-east-1.amazonaws.com/v0/mock \
Content-Type:application/json \
statusCode:=200
```

```bash
http -v POST \
https://$API_GATEWAY_ID.execute-api.us-east-1.amazonaws.com/v0/mock \
Content-Type:application/json \
statusCode:=200
```

## AWS API Gateway with a Lambda Integration

### Validation

```bash
aws cloudformation validate-template \
--template-body file://api-gateway-lambda-integration/template.yaml
```

### Deployment

```bash
aws cloudformation deploy \
--stack-name lambda-api \
--template-file api-gateway-lambda-integration/template.yaml \
--capabilities CAPABILITY_IAM
```

### Testing

```bash
API_GATEWAY_ID=$(aws apigateway get-rest-apis --query 'items[?name==`lambda-api`].id' | grep -o -E "[a-z0-9]+")
```

```bash
http -v POST \
https://$API_GATEWAY_ID.execute-api.us-east-1.amazonaws.com/v0/lambda \
Content-Type:application/json \
```

## EC2

### Prerequisites

* Create an EC2 Key Pair:

```bash
./ec2/create-key-pair.sh <key-name>
```

**Note**: Your private key file must be protected from read and write operations from any other users. If your private key can be read or written to by anyone but you, then SSH ignores your key. For this reason, the private key is given `400` permissions.

The key name should also be updated in `ec2/parameters.json` or `ec2/parameters.properties`.

* Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

### Validation

```bash
aws cloudformation validate-template \
--template-body file://ec2/template.yaml
```

### Deployment

```bash
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://ec2/template.yaml \
--parameters file://ec2/parameters.json
```

Alternatively, using `deploy`:

```bash
aws cloudformation deploy \
--stack-name $STACK_NAME \
--template-file ec2/template.yaml \
--parameter-overrides $(cat ec2/parameters.properties)
```

### Testing

* Testing SSH:

```bash
EC2_PUBLIC_DNS=$(aws cloudformation describe-stacks \
--stack-name $STACK_NAME \
--query 'Stacks[0].Outputs[?OutputKey==`EC2PublicDns`].OutputValue' \
| grep -o -E "[a-zA-Z0-9\.\-]+")
```

```bash
ssh -i ec2/ec2.pem ec2-user@$EC2_PUBLIC_DNS
```

* Testing web server:

```bash
http -v http://$EC2_PUBLIC_DNS
```

## Static Website

### Prerequisites

* Set the domain name purchased through AWS.

```bash
DOMAIN_NAME=<domain-name>
```

The domain name should also be updated in `static-website/parameters.json` or `static-website/parameters.properties`.

* Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

### Validation

```bash
aws cloudformation validate-template \
--template-body file://static-website/template.yaml
```

### Deployment

```bash
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://static-website/template.yaml \
--parameters file://static-website/parameters.json
```

```bash
./static-website/dns-validation.sh $DOMAIN_NAME
```

Alternatively, using `deploy`:

```bash
aws cloudformation deploy \
--stack-name $STACK_NAME \
--template-file static-website/template.yaml \
--parameter-overrides $(cat static-website/parameters.properties)
```

### Testing

```bash
S3_BUCKET_ROOT=$(aws cloudformation describe-stack-resources \
--stack-name $STACK_NAME \
--query 'StackResources[?LogicalResourceId==`S3BucketRoot`].PhysicalResourceId' \
| grep -o -E "[a-zA-Z0-9/-]+")
```

```bash
aws s3 cp --acl "public-read" static-website/index.html s3://$S3_BUCKET_ROOT
```

```bash
http -v https://$DOMAIN_NAME
```

## LAMP Stack with EC2

### Prerequisites

* Create an EC2 Key Pair:

```bash
./lamp-ec2/create-key-pair.sh <key-name>
```

**Note**: Your private key file must be protected from read and write operations from any other users. If your private key can be read or written to by anyone but you, then SSH ignores your key. For this reason, the private key is given `400` permissions.

The key name should also be updated in `lamp-ec2/parameters.json` or `lamp-ec2/parameters.properties`.

* Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

### Validation

```bash
aws cloudformation validate-template \
--template-body file://lamp-ec2/template.yaml
```

### Deployment

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

### Testing

* Testing SSH:

```bash
EC2_PUBLIC_DNS=$(aws cloudformation describe-stacks \
--stack-name $STACK_NAME \
--query 'Stacks[0].Outputs[?OutputKey==`EC2PublicDns`].OutputValue' \
| grep -o -E "[a-zA-Z0-9\.\-]+")
```

```bash
ssh -i lamp-ec2/lamp-ec2.pem ec2-user@$EC2_PUBLIC_DNS
```

* Testing web server:

```bash
http -v http://$EC2_PUBLIC_DNS
```

## LAMP Stack with ASG

### Prerequisites

* Create an EC2 Key Pair:

```bash
./lamp-asg/create-key-pair.sh <key-name>
```

**Note**: Your private key file must be protected from read and write operations from any other users. If your private key can be read or written to by anyone but you, then SSH ignores your key. For this reason, the private key is given `400` permissions.

The key name should also be updated in `lamp-asg/parameters.json` or `lamp-asg/parameters.properties`.

* Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

### Validation

```bash
aws cloudformation validate-template \
--template-body file://lamp-asg/template.yaml
```

### Deployment

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

### Testing

* Testing SSH:

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

**Note**: To become root, execute `sudo -i`.

* Testing web server:

```bash
ALB_PUBLIC_DNS=$(aws cloudformation describe-stacks \
--stack-name $STACK_NAME \
--query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
| grep -o -E "[a-zA-Z0-9\:\/\.\-]+")
```

```bash
http -v $ALB_PUBLIC_DNS
```
