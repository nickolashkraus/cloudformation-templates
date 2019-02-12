# cloudformation-templates

A collection of CloudFormation templates.

## AWS API Gateway with a Mock Integration

### Validation

```bash
aws cloudformation validate-template \
--template-body file://api-gateway-mock-integration/template.yaml
```

### Installation

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

### Installation

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
