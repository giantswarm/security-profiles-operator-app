##@ Custom

SHELL := bash

HELM_SCHEMA_VERSION := 2.5.0
HELM_SCHEMA_URL := https://github.com/losisin/helm-values-schema-json/releases/download/v$(HELM_SCHEMA_VERSION)/helm-values-schema-json_$(HELM_SCHEMA_VERSION)_linux_amd64.tgz
# Resolve helm-schema binary: standalone binary in PATH > helm plugin > fallback download path
_HELM_SCHEMA_STANDALONE := $(shell command -v helm-values-schema-json 2>/dev/null)
_HELM_SCHEMA_PLUGIN := $(shell helm plugin list 2>/dev/null | grep -q '^schema' && echo 'helm schema')
HELM_SCHEMA_BIN := $(or $(_HELM_SCHEMA_STANDALONE),$(_HELM_SCHEMA_PLUGIN),/tmp/helm-values-schema-json)

.PHONY: install-helm-schema generate-upstream-schema

install-helm-schema: ## Install helm-values-schema-json binary if not already installed.
	@echo "====> $@"
	@if [ -n "$(_HELM_SCHEMA_STANDALONE)" ] || [ -n "$(_HELM_SCHEMA_PLUGIN)" ]; then \
		echo "helm-values-schema-json found at: $(HELM_SCHEMA_BIN)"; \
	elif [ -x /tmp/helm-values-schema-json ]; then \
		echo "helm-values-schema-json already downloaded at /tmp/helm-values-schema-json"; \
	else \
		echo "Installing helm-values-schema-json $(HELM_SCHEMA_VERSION)..."; \
		curl -sSL $(HELM_SCHEMA_URL) | tar -xz -C /tmp schema && mv /tmp/schema /tmp/helm-values-schema-json; \
	fi

generate-upstream-schema: install-helm-schema ## Generate JSON schema from upstream values.yaml.
	@echo "====> $@"
	$(HELM_SCHEMA_BIN) \
		-f <($(YQ) '.["security-profiles-operator"]' helm/security-profiles-operator/values.yaml | grep -v '# @schema hidden') \
		-f helm/security-profiles-operator/charts/security-profiles-operator/values.yaml \
		-o helm/security-profiles-operator/charts/security-profiles-operator/values.schema.json \
		--config helm/security-profiles-operator/.schema.yaml

update-deps: generate-upstream-schema helm-docs
