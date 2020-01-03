.PHONY: help clean clean-build clean-pyc clean-test
.PHONY: test unit-test coverage lint check format deps
.DEFAULT_GOAL := help

RED    = \033[0;31m
YELLOW = \033[0;33m
GREEN  = \033[0;32m
RESET  = \033[0m

define BROWSER_PYSCRIPT
import os, webbrowser, sys

try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## run clean-build, clean-pyc, and clean-test

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -f .coverage
	rm -f coverage.xml
	rm -fr cover/
	rm -fr htmlcov/
	rm -fr .pytest_cache

test: deps unit-test coverage lint check ## run unit-test, coverage, lint, and check

unit-test: ## run unit tests
	@set -e; \
	echo 'Running unit tests...' && \
	nosetests . && exit 0 || \
	coverage report -m --fail-under=100 >/dev/null && exit 1

coverage: ## run code coverage
	@set -e; \
	echo 'Running coverage...' && \
	nosetests . && exit 0 || \
	coverage report -m >/dev/null || coverage html; \
	$(BROWSER) htmlcov/index.html

lint: ## check style with flake8
	@flake8 hello tests; \
	if [ $$? -eq 0 ]; then \
	  echo '$(GREEN)Linting successful!$(RESET)'; \
	fi;

check: ## check complexity and docstrings
	@set -e; \
	echo 'Checking complexity...' && \
	failed=0 && \
	for f in $$(find $$(pwd)/hello/ -name '*.py';); do \
		output=$$(python3 -m mccabe --min 9 "$$f") && \
		if [ $(strip "$$output") != "" ]; then \
			echo "$(YELLOW)$$(basename $$f) is too complex.$(RESET)"; \
			echo "$(YELLOW)$$output$(RESET)\n"; \
			failed=1; \
		fi; \
	done && \
	if [ $$failed -eq 1 ]; then \
	  echo '$(RED)Complexity check failed!$(RESET)' && \
		exit 1; \
	fi && \
	echo 'Checking docstrings...' && \
	pydocstyle . && \
	echo '$(GREEN)Checks successful!$(RESET)'

format: ## format code and imports
	@set -e; \
	echo 'Formatting code...' && \
	yapf --in-place --parallel --recursive . && \
	echo 'Formatting imports...' && \
	isort --recursive . && \
	echo '$(GREEN)Formatting successful!$(RESET)'

deps:
	pip install -r requirements_dev.txt
