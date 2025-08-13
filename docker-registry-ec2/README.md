# Docker Registry with EC2

## Prerequisites

- Create an EC2 Key Pair:

```bash
./docker-registry-ec2/create-key-pair.sh <key-name>
```

**Note**: Your private key file must be protected from read and write operations from any other users. If your private key can be read or written to by anyone but you, then SSH ignores your key. For this reason, the private key is given `400` permissions.

The key name should also be updated in `docker-registry-ec2/parameters.json` or `docker-registry-ec2/parameters.properties`.

- Set a CloudFormation stack name:

```bash
STACK_NAME=<stack-name>
```

## Validation

```bash
aws cloudformation validate-template \
--template-body file://docker-registry-ec2/template.yaml
```

## Deployment

```bash
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://docker-registry-ec2/template.yaml \
--parameters file://docker-registry-ec2/parameters.json
```

Alternatively, using `deploy`:

```bash
aws cloudformation deploy \
--stack-name $STACK_NAME \
--template-file docker-registry-ec2/template.yaml \
--parameter-overrides $(cat docker-registry-ec2/parameters.properties)
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
ssh -i docker-registry-ec2/docker-registry-ec2.pem ec2-user@$EC2_PUBLIC_DNS
```

- Testing the Docker Registry:

In order to log in to the Docker Registry, you will need to add the registry to your list of insecure registries.

To do this, go **Preference** > **Daemon** > and add `<ec2-public-dns:port>` to **Insecure registries:**.

**Example**: `ec2-54-211-197-167.compute-1.amazonaws.com:5043`

```bash
docker login $EC2_PUBLIC_DNS:5043
echo "FROM alpine" > Dockerfile
docker build -t alpine:latest .
docker tag alpine $EC2_PUBLIC_DNS:5043/alpine
docker push $EC2_PUBLIC_DNS:5043/alpine
docker pull $EC2_PUBLIC_DNS:5043/alpine
rm Dockerfile
```
