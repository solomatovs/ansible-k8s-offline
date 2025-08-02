# ==========================================
# Makefile for building Kubernetes components with Ansible
# ==========================================
.PHONY: build clean

ANSIBLE_INVENTORY := inventory/hosts.yml

build:
	@echo "Building all components from source..."
	ansible-playbook -i $(ANSIBLE_INVENTORY) playbooks/build.yml

clean:
	@echo "Cleaning build artifacts..."
	rm -rf playbooks/artifacts

help:
	@echo "Available targets:"
	@echo "  build             - Build all components"
	@echo "  clean             - Clean all artifacts"
