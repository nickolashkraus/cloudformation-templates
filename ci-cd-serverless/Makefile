.PHONY: help clean test format
.PHONY: package-code package-lambda
.PHONY: sls-deploy sls-remove
.PHONY: cfn-validate cfn-deploy cfn-delete
.DEFAULT_GOAL := help

STACK_NAME := ci-cd-serverless
STAGE := dev
CODE_DIR := code
LAMBDA_DIR := hello
PACKAGE_DIR := lambda

RED    = \033[0;31m
YELLOW = \033[0;33m
GREEN  = \033[0;32m
RESET  = \033[0m

# For CodeBuild, each input source is installed in its own directory. This
# directory is stored in the built-in environment variable $CODEBUILD_SRC_DIR
# for the primary source and $CODEBUILD_SRC_DIR_<InputArtifactName> for all
# other sources.
# Note: CODEBUILD_SRC_DIR is the directory path that CodeBuild uses for the
# build.
CODEBUILD_SRC_DIR ?= $$(pwd)
CODEBUILD_SRC_DIR_BUILD_ARTIFACT ?= $$(pwd)

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help: ## display help information
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: ## remove deployment and Python artifacts
	rm -f ${CODE_DIR}.zip
	rm -f ${PACKAGE_DIR}.zip
	rm -rf ${CODE_DIR}
	rm -rf ${PACKAGE_DIR}
	@$(MAKE) -C ${LAMBDA_DIR} clean

package-code: clean ## create CodeCommit code repository package
	mkdir -p ${CODE_DIR}
	cp -R cloudformation codebuild ${LAMBDA_DIR} ${CODE_DIR}
	find . -type f -depth 1 -exec cp {} ${CODE_DIR} \;
	find ${CODE_DIR} -type f -name "*.swp" -exec rm {} \;
	cd ${CODE_DIR} && \
	zip -9 -q -r ../$(CODE_DIR).zip * && \
	cd .. && rm -rf $(CODE_DIR)

package-lambda: clean ## create AWS Lambda function deployment package
	mkdir -p ${PACKAGE_DIR}
	pip3 install -r ${LAMBDA_DIR}/requirements.txt -t ${PACKAGE_DIR}
	cp -R ${LAMBDA_DIR}/hello ${PACKAGE_DIR}
	cd ${PACKAGE_DIR} && \
	zip -9 -q --exclude '*dist-info*' '*__pycache__*' -r ../${PACKAGE_DIR}.zip * && \
	cd .. && rm -rf $(PACKAGE_DIR)

test: ## run tests
	@$(MAKE) -C ${LAMBDA_DIR} test

format: ## format code and imports
	@$(MAKE) -C ${LAMBDA_DIR} format

sls-deploy: ## deploy AWS Lambda function via Serverless
	@if [ -s "$$HOME/.nvm/nvm.sh" ]; then \
		source $$HOME/.nvm/nvm.sh; \
	fi; \
	if [ ! -e ${CODEBUILD_SRC_DIR}/${PACKAGE_DIR}.zip ]; then \
		cp -u \
			${CODEBUILD_SRC_DIR_BUILD_ARTIFACT}/${PACKAGE_DIR}.zip \
			${CODEBUILD_SRC_DIR}/${PACKAGE_DIR}.zip; \
	fi; \
	serverless deploy -v --stage ${STAGE}

sls-remove: ## remove AWS Lambda function via Serverless
	@if [ -s "$$HOME/.nvm/nvm.sh" ]; then \
		source $$HOME/.nvm/nvm.sh; \
	fi; \
	serverless remove -v --stage ${STAGE}

code-gen: ## generate CloudFormation template and build spec files
	sed '/#/d' docs/cloudformation/annotated.yaml > cloudformation/template.yaml
	sed '/#/d' docs/codebuild/docker/annotated.yml > codebuild/docker/buildspec.yml
	sed '/#/d' docs/codebuild/build/annotated.yml > codebuild/build/buildspec.yml
	sed '/#/d' docs/codebuild/deploy/annotated.yml > codebuild/deploy/buildspec.yml
	gsed -i '12i# ~' cloudformation/template.yaml

cfn-validate: ## validate CloudFormation template
	@OUTPUT=$$(aws cloudformation validate-template \
    --template-body file://cloudformation/template.yaml 2>&1); \
	if [ $$? -eq 255 ]; then \
		echo "$(RED)$$OUTPUT$(RESET)\n" && \
		exit 1; \
	fi;

cfn-deploy: cfn-validate ## deploy CloudFormation stack
	@aws cloudformation describe-stacks --stack-name $(STACK_NAME) >/dev/null 2>&1; \
	if [ $$? -eq 255 ]; then \
		echo "$(YELLOW)CloudFormation stack '$(STACK_NAME)' does not exist.$(RESET)" && \
		echo "$(YELLOW)Creating CloudFormation stack...$(RESET)" && \
		mkdir -p .cloudformation && \
		sed '/# ~/,$$d' cloudformation/template.yaml > .cloudformation/create.yaml && \
		cp -R cloudformation/template.yaml .cloudformation/update.yaml && \
		aws cloudformation deploy \
			--stack-name $(STACK_NAME) \
			--template-file .cloudformation/create.yaml \
			--capabilities CAPABILITY_NAMED_IAM && \
		$(MAKE) package-code && \
		aws s3 cp ${CODE_DIR}.zip s3://$(STACK_NAME)-s3-codecommit-code && \
		aws cloudformation deploy \
			--stack-name $(STACK_NAME) \
			--template-file .cloudformation/update.yaml \
			--capabilities CAPABILITY_NAMED_IAM && \
		rm -rf .cloudformation && \
		echo "$(GREEN)CloudFormation stack successfully deployed!$(RESET)" && \
		exit 0; \
	fi; \
	aws cloudformation deploy \
		--stack-name $(STACK_NAME) \
		--template-file cloudformation/template.yaml \
		--capabilities CAPABILITY_NAMED_IAM; \
	if [ $$? -eq 255 ]; then \
		exit 0; \
	fi; \
	echo "$(GREEN)CloudFormation stack successfully deployed!$(RESET)"

cfn-delete: ## delete CloudFormation stack
	@aws cloudformation describe-stacks --stack-name $(STACK_NAME) >/dev/null 2>&1; \
	if [ $$? -eq 255 ]; then \
		echo "$(YELLOW)CloudFormation stack '$(STACK_NAME)' does not exist.$(RESET)" && \
		exit 0; \
	fi; \
	echo "$(YELLOW)Deleting CloudFormation stack...$(RESET)" && \
	aws s3 rm s3://$(STACK_NAME)-s3-codecommit-code --recursive && \
	aws s3 rm s3://$(STACK_NAME)-s3-artifact-store --recursive && \
	aws ecr list-images --repository-name $(STACK_NAME)/build | jq '.imageIds | .[].imageDigest' | \
	while read i; do \
		aws ecr batch-delete-image --repository-name $(STACK_NAME)/build --image-ids imageDigest=$$i; \
	done && \
	aws ecr list-images --repository-name $(STACK_NAME)/deploy | jq '.imageIds | .[].imageDigest' | \
	while read i; do \
		aws ecr batch-delete-image --repository-name $(STACK_NAME)/deploy --image-ids imageDigest=$$i; \
	done && \
	aws cloudformation delete-stack --stack-name $(STACK_NAME) && \
	echo "$(GREEN)CloudFormation stack successfully deleted!$(RESET)"
