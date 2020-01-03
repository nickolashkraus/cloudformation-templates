.PHONY: help clean
.PHONY: package-code
.PHONY: cfn-validate cfn-deploy cfn-delete
.DEFAULT_GOAL := help

STACK_NAME := ci-cd
CODE_DIR := code

RED    = \033[0;31m
YELLOW = \033[0;33m
GREEN  = \033[0;32m
RESET  = \033[0m

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

clean: ## remove deployment artifacts
	rm -f ${CODE_DIR}.zip
	rm -rf ${CODE_DIR}

code-gen: ## generate CloudFormation template and build spec files
	sed '/#/d' docs/cloudformation/annotated.yaml > cloudformation/template.yaml
	sed '/#/d' docs/codebuild/annotated.yml > codebuild/buildspec.yml
	gsed -i '12i# ~' cloudformation/template.yaml

package-code: clean code-gen ## create CodeCommit code repository package
	mkdir -p ${CODE_DIR}
	cp -R cloudformation codebuild ${CODE_DIR}
	find . -type f -depth 1 -exec cp {} ${CODE_DIR} \;
	find ${CODE_DIR} -type f -name "*.swp" -exec rm {} \;
	cd ${CODE_DIR} && \
	zip -9 -q -r ../${CODE_DIR}.zip * && \
	cd .. && rm -rf $(CODE_DIR)

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
	aws cloudformation delete-stack --stack-name $(STACK_NAME) && \
	echo "$(GREEN)CloudFormation stack successfully deleted!$(RESET)"
