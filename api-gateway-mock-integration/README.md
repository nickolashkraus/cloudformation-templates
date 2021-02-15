# AWS API Gateway with a Mock Integration

## Validation

```bash
aws cloudformation validate-template \
--template-body file://api-gateway-mock-integration/template.yaml
```

## Deployment

```bash
aws cloudformation deploy \
--stack-name mock-api \
--template-file api-gateway-mock-integration/template.yaml
```

## Testing

```bash
API_GATEWAY_ID=$(aws apigateway get-rest-apis --query 'items[?name==`mock-api`].id' | grep -o -E "[a-z0-9]+")
```

```bash
http -v POST \
https://$API_GATEWAY_ID.execute-api.us-east-1.amazonaws.com/v0/mock \
Content-Type:application/json \
statusCode:=200
```
