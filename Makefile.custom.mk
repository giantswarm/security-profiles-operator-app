##@ Custom

HELM_SCHEMA_VERSION := 2.5.0
HELM_SCHEMA_URL := https://github.com/losisin/helm-values-schema-json/releases/download/v$(HELM_SCHEMA_VERSION)/helm-values-schema-json_$(HELM_SCHEMA_VERSION)_linux_amd64.tgz
# Resolve helm-schema binary: standalone binary in PATH > helm plugin > fallback download path
_HELM_SCHEMA_STANDALONE := $(shell command -v helm-values-schema-json 2>/dev/null)
_HELM_SCHEMA_PLUGIN := $(shell helm plugin list 2>/dev/null | grep -q '^schema' && echo 'helm schema')
HELM_SCHEMA_BIN := $(or $(_HELM_SCHEMA_STANDALONE),$(_HELM_SCHEMA_PLUGIN),/tmp/helm-values-schema-json)

YQ_VERSION := 4.44.3
YQ_BIN := $(or $(shell command -v yq 2>/dev/null),/tmp/yq)
YQ_URL := https://github.com/mikefarah/yq/releases/download/v$(YQ_VERSION)/yq_linux_amd64

.PHONY: install-helm-schema install-yq generate-upstream-schema

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

install-yq: ## Install yq binary if not already installed.
	@echo "====> $@"
	@if [ -x "$(YQ_BIN)" ]; then \
		echo "yq already installed at $(YQ_BIN)"; \
	else \
		echo "Installing yq $(YQ_VERSION)..."; \
		curl -sSL $(YQ_URL) -o /tmp/yq && chmod +x /tmp/yq; \
	fi

generate-upstream-schema: install-helm-schema install-yq ## Generate JSON schema from upstream values.yaml.
	@echo "====> $@"
	$(HELM_SCHEMA_BIN) \
    	-f <($(YQ_BIN) '.["security-profiles-operator"]' helm/security-profiles-operator/values.yaml | grep -v '# @schema hidden') \
		-f helm/security-profiles-operator/charts/security-profiles-operator/values.yaml \
		-o helm/security-profiles-operator/charts/security-profiles-operator/values.schema.json \
		--no-additional-properties

update-deps: generate-upstream-schema
