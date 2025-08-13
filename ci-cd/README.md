# CI/CD

## Prerequisites

- Set the CloudFormation stack name:

```bash
STACK_NAME=ci-cd
```

**Note**: The stack name will be used in the physical ID of resources where applicable.

## Validate

```bash
make cfn-validate
```

## Deploy

```bash
make cfn-deploy
```

### Initial Deploy

The initial deploy of this stack is.. special.

You cannot deploy a CodeCommit repository and S3 bucket that contains the zipped artifact that serves as the initial commit at the same time.

To circumvent this, first only the S3 bucket is deployed, then the zipped artifact is uploaded to S3, and finally the full CloudFormation stack is deployed.

This is handled transparently by `make cfn-deploy`.

**Note**: The `# ~` in `cloudformation/template.yaml` designates the separation between the first and second deploy.

## Delete

```bash
make cfn-delete
```

**Note**: S3 objects must be removed before the CloudFormation stack can be deleted.

This is handled transparently by `make cfn-delete`.

## Code Generation

`cloudformation/template.yaml` and `codebuild/buildspec.yml` are generated using `docs/cloudformation/annotated.yaml` and `docs/codebuild/annotated.yml`, respectively:

```bash
make code-gen
```
