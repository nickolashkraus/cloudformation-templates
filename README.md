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

## Static Website

### Prerequisites

* Set the domain name purchased through AWS.

```bash
DOMAIN_NAME=<domain-name>
```

The domain name should also be updated in `static-website/parameters.json`.

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
