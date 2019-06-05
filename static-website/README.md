# Static Website

## Prerequisites

* Set the domain name purchased through AWS.

```bash
DOMAIN_NAME=<domain-name>
```

The domain name should also be updated in `static-website/parameters.json` or `static-website/parameters.properties`.

* Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

## Validation

```bash
aws cloudformation validate-template \
--template-body file://static-website/template.yaml
```

## Deployment

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

## Testing

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
