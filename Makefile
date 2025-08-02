# Makefile for Kubernetes Build Project
# Builds Go compilers and Kubernetes components from source using Ansible

# Default values
INVENTORY ?= inventory
PLAYBOOK_DIR = playbooks
ARTIFACT_DIR = artifacts
BUILD_HOST ?= docker_build

# Color codes for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)Kubernetes Build Project$(NC)"
	@echo "=========================="
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Available components:$(NC)"
	@echo "  $(GREEN)go$(NC)         - Build Go compilers"
	@echo "  $(GREEN)runc$(NC)       - Build runc container runtime"
	@echo "  $(GREEN)cni$(NC)        - Build CNI plugins"
	@echo "  $(GREEN)containerd$(NC) - Build containerd"
	@echo "  $(GREEN)etcd$(NC)       - Build etcd"
	@echo "  $(GREEN)kubernetes$(NC) - Build Kubernetes"
	@echo "  $(GREEN)all$(NC)        - Build all components"

.PHONY: clean
clean: ## Clean local artifact directories
	@echo "$(YELLOW)Cleaning artifact directories...$(NC)"
	@rm -rf $(ARTIFACT_DIR)
	@echo "$(GREEN)Cleanup completed$(NC)"

.PHONY: clean-remote
clean-remote: ## Clean remote artifact directories
	@echo "$(YELLOW)Cleaning remote artifact directories...$(NC)"
	ansible $(BUILD_HOST) -i $(INVENTORY) -m shell -a "rm -rf /tmp/ansible" --become
	@echo "$(GREEN)Remote cleanup completed$(NC)"

.PHONY: build-all
build-all: ## Build all components (Go + all applications)
	@echo "$(BLUE)Starting full build process...$(NC)"
	@echo "$(YELLOW)This will build Go compilers sequentially, then all applications$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/build.yml -e build_app=all
	@echo "$(GREEN)Full build completed successfully$(NC)"

.PHONY: build-go
build-go: ## Build Go compilers only
	@echo "$(BLUE)Building Go compilers...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/build.yml -e build_app=go
	@echo "$(GREEN)Go build completed successfully$(NC)"

.PHONY: build-runc
build-runc:  ## Build runc container runtime
	@echo "$(BLUE)Building runc...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/build.yml -e build_app=runc
	@echo "$(GREEN)runc build completed successfully$(NC)"

.PHONY: build-cni
build-cni:  ## Build CNI plugins
	@echo "$(BLUE)Building CNI plugins...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/build.yml -e build_app=cni
	@echo "$(GREEN)CNI build completed successfully$(NC)"

.PHONY: build-containerd
build-containerd:  ## Build containerd
	@echo "$(BLUE)Building containerd...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/build.yml -e build_app=containerd
	@echo "$(GREEN)containerd build completed successfully$(NC)"

.PHONY: build-etcd
build-etcd:  ## Build etcd
	@echo "$(BLUE)Building etcd...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/build.yml -e build_app=etcd
	@echo "$(GREEN)etcd build completed successfully$(NC)"

.PHONY: build-kubernetes
build-kubernetes:  ## Build Kubernetes
	@echo "$(BLUE)Building Kubernetes...$(NC)"
	@echo "$(YELLOW)Note: Requires Go compilers to be built first$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/build.yml -e build_app=kubernetes
	@echo "$(GREEN)Kubernetes build completed successfully$(NC)"

.PHONY: build-runtime
build-runtime:  ## Build container runtime components (runc, cni, containerd)
	@echo "$(BLUE)Building container runtime components...$(NC)"
	$(MAKE) build-runc
	$(MAKE) build-cni
	$(MAKE) build-containerd
	@echo "$(GREEN)Container runtime build completed successfully$(NC)"

.PHONY: build-core
build-core:  ## Build core Kubernetes stack (etcd + kubernetes)
	@echo "$(BLUE)Building core Kubernetes stack...$(NC)"
	$(MAKE) build-etcd
	$(MAKE) build-kubernetes
	@echo "$(GREEN)Core Kubernetes build completed successfully$(NC)"

.PHONY: build-incremental
build-incremental:  ## Incremental build (Go -> Runtime -> Core)
	@echo "$(BLUE)Starting incremental build process...$(NC)"
	$(MAKE) build-go
	$(MAKE) build-runtime
	$(MAKE) build-core
	@echo "$(GREEN)Incremental build completed successfully$(NC)"

.PHONY: list-artifacts
list-artifacts: ## List built artifacts
	@echo "$(BLUE)Built artifacts:$(NC)"
	@if [ -d "$(ARTIFACT_DIR)" ]; then \
		find $(ARTIFACT_DIR) -name "*.tar.gz" -printf "  $(GREEN)%P$(NC)\n" 2>/dev/null || \
		find $(ARTIFACT_DIR) -name "*.tar.gz" | sed 's|^$(ARTIFACT_DIR)/||' | sed 's|^|  $(GREEN)|' | sed 's|$$|$(NC)|'; \
	else \
		echo "  $(YELLOW)No artifacts found. Run 'make build-all' first.$(NC)"; \
	fi

# Advanced targets
.PHONY: build-parallel
build-parallel:  ## Build applications in parallel (after Go)
	@echo "$(BLUE)Building Go compilers first...$(NC)"
	$(MAKE) build-go
	@echo "$(BLUE)Building applications in parallel...$(NC)"
	@echo "$(YELLOW)Note: This may put high load on build hosts$(NC)"
	@( \
		$(MAKE) build-runc & \
		$(MAKE) build-cni & \
		$(MAKE) build-containerd & \
		$(MAKE) build-etcd & \
		wait; \
		$(MAKE) build-kubernetes \
	)
	@echo "$(GREEN)Parallel build completed successfully$(NC)"

.PHONY: watch-build
watch-build: ## Watch build progress (requires: make build-* in another terminal)
	@echo "$(BLUE)Watching build progress... (Press Ctrl+C to stop)$(NC)"
	@while true; do \
		clear; \
		echo "$(BLUE)Build Progress - $$(date)$(NC)"; \
		echo "====================================="; \
		$(MAKE) list-artifacts 2>/dev/null; \
		echo ""; \
		echo "Disk usage: $$(du -sh $(ARTIFACT_DIR) 2>/dev/null | cut -f1 || echo 'N/A')"; \
		sleep 5; \
	done
