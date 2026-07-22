##@ Custom

HELM_SCHEMA_VERSION := 2.5.0
HELM_SCHEMA_BIN := /tmp/helm-values-schema-json
HELM_SCHEMA_URL := https://github.com/losisin/helm-values-schema-json/releases/download/v$(HELM_SCHEMA_VERSION)/helm-values-schema-json_$(HELM_SCHEMA_VERSION)_linux_amd64.tgz

.PHONY: install-helm-schema generate-upstream-schema

install-helm-schema: ## Install helm-values-schema-json binary if not already installed.
	@echo "====> $@"
	@if [ -x $(HELM_SCHEMA_BIN) ]; then \
		echo "helm-values-schema-json already installed"; \
	else \
		echo "Installing helm-values-schema-json $(HELM_SCHEMA_VERSION)..."; \
		curl -sSL $(HELM_SCHEMA_URL) | tar -xz -C /tmp schema && mv /tmp/schema $(HELM_SCHEMA_BIN); \
	fi

generate-upstream-schema: install-helm-schema ## Generate JSON schema from upstream values.yaml.
	@echo "====> $@"
	$(HELM_SCHEMA_BIN) \
		-f helm/security-profiles-operator/charts/security-profiles-operator/values.yaml \
		-o helm/security-profiles-operator/charts/security-profiles-operator/values.schema.json \
		--no-additional-properties

update-deps: generate-upstream-schema
