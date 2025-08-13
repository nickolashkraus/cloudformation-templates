# Static Website with Certificate Validator

## Prerequisites

- Set the domain name purchased through AWS.

```bash
DOMAIN_NAME=<domain-name>
```

The domain name should also be updated in `static-website-cv/parameters.json` or `static-website-cv/parameters.properties`.

- Set the Amazon Resource Name (ARN) of the custom resource in `static-website-cv/parameters.json` or `static-website-cv/parameters.properties`.

**Example**

```json
[
  {
    "ParameterKey": "ServiceToken",
    "ParameterValue": "arn:aws:lambda:<region>:<account-id>:function:<function-name>"
  }
]
```

```properties
ServiceToken=arn:aws:lambda:<region>:<account-id>:function:<function-name>
```

**Note**: The service token must be in the same region as the CloudFormation stack.

- Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

## Validation

```bash
aws cloudformation validate-template \
--template-body file://static-website-cv/template.yaml
```

## Deployment

```bash
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://static-website-cv/template.yaml \
--parameters file://static-website-cv/parameters.json
```

Alternatively, using `deploy`:

```bash
aws cloudformation deploy \
--stack-name $STACK_NAME \
--template-file static-website-cv/template.yaml \
--parameter-overrides $(cat static-website-cv/parameters.properties)
```

## Testing

```bash
S3_BUCKET_ROOT=$(aws cloudformation describe-stack-resources \
--stack-name $STACK_NAME \
--query 'StackResources[?LogicalResourceId==`S3BucketRoot`].PhysicalResourceId' \
| grep -o -E "[a-zA-Z0-9/-]+")
```

```bash
aws s3 cp --acl "public-read" static-website-cv/index.html s3://$S3_BUCKET_ROOT
```

```bash
http -v https://$DOMAIN_NAME
```

```bash
http -v https://www.$DOMAIN_NAME
```
