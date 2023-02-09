# Linters

.PHONY: lint
lint: chart-lint docs-lint tests-lint

.PHONY: chart-lint
chart-lint: helm-lint yaml-lint shellcheck

.PHONY: docs-lint
docs-lint: markdown-lint markdown-links-lint

.PHONY: tests-lint
tests-lint: template-tests-lint integration-tests-lint

.PHONY: markdown-lint
markdown-lint:
	prettier --check "**/*.md"
	markdownlint --config .markdownlint.jsonc \
		deploy/docs \
		docs \
		CHANGELOG.md

.PHONY: helm-lint
helm-lint: helm-version
# TODO: we should add back the --strict flag but because we have made the PodDisruptionBudget
# API version dependent on cluster capabilities and because helm lint does not accept
# an --api-versions flag like helm template does we cannot make this configurable.
#
# Perhaps we could at some point run this against a cluster with particular k8s version?
#
# https://github.com/SumoLogic/sumologic-kubernetes-collection/pull/1943
	helm lint \
		--set sumologic.accessId=X \
		--set sumologic.accessKey=X \
		deploy/helm/sumologic/
	helm lint --with-subcharts \
		--set sumologic.accessId=X \
		--set sumologic.accessKey=X \
		deploy/helm/sumologic/ || true

.PHONY: yaml-lint
yaml-lint:
	prettier --check "**/*.yaml"

.PHONY: shellcheck
shellcheck:
	./ci/shellcheck.sh

.PHONY: markdown-links-lint
markdown-links-lint:
	./ci/markdown_links_lint.sh

.PHONY: check-configuration-keys
check-configuration-keys:
	./ci/check_configuration_keys.py --values deploy/helm/sumologic/values.yaml --readme deploy/helm/sumologic/README.md

.PHONY: template-tests-lint
template-tests-lint:
	make -C ./tests/helm golint

.PHONY: integration-tests-lint
integration-tests-lint:
	make -C ./tests/integration golint

# Formatters

.PHONY: format
format: markdown-table-formatter-format yaml-format

.PHONY: markdown-format
markdown-format:
	prettier -w "**/*.md"

.PHONY: yaml-format
yaml-format:
	prettier -w "**/*.yaml"

# Tests
.PHONY: test
test: test-templates

## Template tests
.PHONY: test-templates
test-templates:
	make helm-dependency-update
	make -C ./tests/helm test

## Integration tests
.PHONY: test-integration
make test-integration:
	make -C ./tests/integration test


# Changelog management
## We use Towncrier (https://towncrier.readthedocs.io) for changelog management

## Usage: make add-changelog-entry
.PHONY: add-changelog-entry
add-changelog-entry:
	./ci/add-changelog-entry.sh

## Consume the files in .changelog and update CHANGELOG.md
## We also format it afterwards to make sure it's consistent with our style
## Usage: make update-changelog VERSION=x.x.x
.PHONY: update-changelog
update-changelog:
ifndef VERSION
	$(error Usage: make update-changelog VERSION=x.x.x)
endif
	towncrier build --yes --version $(VERSION)
	prettier -w CHANGELOG.md
	git add CHANGELOG.md

## Check if the branch relative to main adds a changelog entry
.PHONY: check-changelog
check-changelog:
	towncrier check

# Various utilities
.PHONY: push-helm-chart
push-helm-chart:
	./ci/push-helm-chart.sh

.PHONY: helm-version
helm-version:
	helm version

.PHONY: helm-dependency-update
helm-dependency-update: helm-version
	helm dependency update deploy/helm/sumologic

.PHONY: markdown-link-check
markdown-link-check:
	./ci/markdown_link_check.sh

# Vagrant commands
.PHONY: vup
vup:
	vagrant up

.PHONY: vssh
vssh:
	vagrant ssh -c 'cd /sumologic; exec "$$SHELL"'

.PHONY: vhalt
vhalt:
	vagrant halt

.PHONY: vdestroy
vdestroy:
	vagrant destroy -f
