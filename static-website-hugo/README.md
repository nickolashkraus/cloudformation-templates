# Static Website Hugo

**Note**: The Terraform version of this CloudFormation stack can be found at [here](https://github.com/infrable-io/terraform-aws-static-website/tree/master/examples/static-website-hugo).

## Prerequisites

* Set the domain name purchased through AWS.

```bash
DOMAIN_NAME=<domain-name>
```

The domain name should also be updated in `static-website-hugo/parameters.json` or `static-website-hugo/parameters.properties`.

* Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

## Validation

```bash
aws cloudformation validate-template \
--template-body file://static-website-hugo/template.yaml
```

## Deployment

```bash
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://static-website-hugo/template.yaml \
--parameters file://static-website-hugo/parameters.json
```

Alternatively, using `deploy`:

```bash
aws cloudformation deploy \
--stack-name $STACK_NAME \
--template-file static-website-hugo/template.yaml \
--parameter-overrides $(cat static-website-hugo/parameters.properties)
```

## DNS Validation

To automate DNS validation, run the following script:

```bash
./static-website-hugo/dns-validation.sh $DOMAIN_NAME $STACK_NAME
```

## Testing

```bash
S3_BUCKET_ROOT=$(aws cloudformation describe-stack-resources \
--stack-name $STACK_NAME \
--query 'StackResources[?LogicalResourceId==`S3BucketRoot`].PhysicalResourceId' \
| grep -o -E "[a-zA-Z0-9/-]+")
```

```bash
./static-website-hugo/deploy.sh
```

```bash
http -v https://$DOMAIN_NAME
```
