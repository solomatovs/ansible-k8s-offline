# Kubernetes Build from Source

🚀 **Automated Kubernetes and Container Runtime Build System**

This project provides a complete Ansible-based automation system for building Kubernetes and its ecosystem components from source code. It builds Go compilers sequentially and then compiles all necessary container runtime and orchestration components.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Build Process](#build-process)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

This automation system builds the complete Kubernetes stack from source:

- **Go Compilers**: Sequential compilation starting from Go 1.4 up to the latest version
- **Container Runtime**: runc, CNI plugins, containerd
- **Key-Value Store**: etcd (multiple versions)
- **Orchestration**: Kubernetes itself

All components are built using Docker containers for isolation and reproducibility, with artifacts stored locally for distribution.

## ✨ Features

- 🔄 **Sequential Go Compilation**: Each Go version built with the previous one
- 🐳 **Docker-based Builds**: Isolated, reproducible build environments
- 📦 **Artifact Management**: Automatic packaging and local storage
- 🎛️ **Flexible Configuration**: Easy version and component management
- 🛠️ **Multiple Build Strategies**: Full, incremental, parallel, and custom builds
- 🧹 **Cleanup Tools**: Docker and artifact cleanup utilities
- 📊 **Progress Monitoring**: Build status and artifact tracking

## 🔧 Prerequisites

### System Requirements
- **Ansible**: 2.9+ with community.general collection
- **Docker**: 20.10+ on build hosts
- **Git**: For source code cloning
- **Make**: For using the provided Makefile
- **Python**: 3.6+ for Ansible

### Build Host Requirements
- Linux-based system (Ubuntu 20.04+ or CentOS 8+ recommended)
- Docker daemon running with sufficient privileges
- Minimum 4GB RAM, 50GB free disk space
- Network access to GitHub and proxy.golang.org

### Network Requirements
- Access to GitHub repositories
- Access to Go module proxy (proxy.golang.org)
- SSH access to build hosts

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd kubernetes-build
```

### 2. Configure Inventory
Create an inventory file with your build hosts:
```ini
[docker_build]
build-host-1 ansible_host=192.168.1.100 ansible_user=ubuntu
build-host-2 ansible_host=192.168.1.101 ansible_user=ubuntu
```

### 3. Test Connectivity
```bash
make ping INVENTORY=inventory
```

### 4. Start Building
```bash
# Full build (recommended for first run)
make build-all INVENTORY=inventory

# Or incremental build
make build-incremental INVENTORY=inventory
```

### 5. Check Results
```bash
make list-artifacts
make status
```

## 📁 Project Structure

```
kubernetes-build/
├── Makefile                                # Build automation and utilities
├── README.md                               # This file
├── inventory                               # Ansible inventory file
├── group_vars/
│   └── all.yml                             # Global configuration
├── playbooks/
│   └── build.yml                           # Main build playbook
├── roles/
│   ├── build-go/                           # Go compiler build role
│   |   ├── templates/
│   |   |   ├── Dockerfile-1.4.j2           # Go 1.4 bootstrap
│   |   |   └── Dockerfile.j2               # Standard Go builds
│   │   └── tasks/
│   │       ├── main.yml
│   │       └── build-version.yml
│   └── build-app/                          # Application build role
│       ├── templates/
│       |   ├── Dockerfile-containerd.j2    # containerd build
│       |   ├── Dockerfile-etcd-3.4.j2      # etcd 3.4.x build
│       |   ├── Dockerfile-etcd-3.6.j2      # etcd 3.6.x build
│       |   └── Dockerfile-kubernetes.j2    # Kubernetes build
│       └── tasks/
│           ├── main.yml
│           └── build-version.yml
└── artifacts/                              # Build artifacts (created during build)
    ├── src/                                # Source archives
    └── bin/                                # Binary archives
```

## ⚙️ Configuration

### Version Configuration (`group_vars/all.yml`)

The main configuration file defines all component versions and build parameters:

#### Go Versions
```yaml
go:
  versions:
    - version: "go1.4"          # Bootstrap compiler
      dockerfile: "Dockerfile-1.4.j2"
    - version: "go1.22.6"       # Latest stable
      dockerfile: "Dockerfile.j2"
```

#### Application Versions
```yaml
apps:
  - name: kubernetes
    repo: "https://github.com/kubernetes/kubernetes.git"
    versions:
      - version: "v1.33.3"
        dockerfile: "Dockerfile-kubernetes.j2"
        go_version: "go1.22.6"   # Specific Go version
```

### Directory Structure
- **Local Artifacts**: `./artifacts/` (configurable)
- **Remote Build**: `/tmp/ansible/` on build hosts
- **Source Archives**: `artifacts/src/`
- **Binary Archives**: `artifacts/bin/`

## 🔨 Build Process

### Sequential Go Compilation
1. **Bootstrap**: Go 1.4 built from C sources
2. **Chain Building**: Each version built with previous Go compiler
3. **Final**: Latest Go used for all applications

### Application Build Flow
1. **Source Preparation**: Git clone and archive
2. **Docker Build**: Isolated compilation environment
3. **Artifact Extraction**: Binaries copied from containers
4. **Local Storage**: Archives transferred to local system

### Build Strategies

#### Full Build (`make build-all`)
- Builds all Go versions sequentially
- Builds all applications with latest Go
- Recommended for clean environments

#### Incremental Build (`make build-incremental`)
- Go → Runtime Components → Core Components
- Good for development iterations

#### Parallel Build (`make build-parallel`)
- Go built sequentially (dependency requirement)
- Applications built in parallel (higher resource usage)

#### Custom Build (`make build-custom`)
- Build specific components only
- Useful for development and testing

## 💡 Usage Examples

### Basic Operations
```bash
# Build only Go compilers
make build-go

# Build only container runtime stack
make build-runtime

# Build specific components
make build-runc
make build-cni
make build-containerd
make build-etcd
make build-kubernetes
```

### Development Workflow
```bash
# Watch build progress (in separate terminal)
make watch-build

# Clean and rebuild
make clean
make build-kubernetes

# List current artifacts
make list-artifacts
```

### Maintenance Operations
```bash
# Clean local artifacts
make clean

# Clean remote build directories
make clean-remote
```

### Advanced Usage
```bash
# Use custom inventory
make build-all INVENTORY=production-hosts

# Build with specific build host group
make build-all BUILD_HOST=gpu_builders

# Parallel build strategy
make build-parallel
```

## 🎛️ Available Commands

### Build Commands
| Command | Description |
|---------|-------------|
| `make build-all` | Build everything (Go + all apps) |
| `make build-go` | Build Go compilers only |
| `make build-runc` | Build runc container runtime |
| `make build-cni` | Build CNI plugins |
| `make build-containerd` | Build containerd |
| `make build-etcd` | Build etcd |
| `make build-kubernetes` | Build Kubernetes only |
| `make build-runtime` | Build runtime components (runc, cni, containerd) |
| `make build-core` | Build core components (etcd + kubernetes) |
| `make build-incremental` | Sequential build strategy (Go → Runtime → Core) |
| `make build-parallel` | Parallel build strategy |

### Management Commands
| Command | Description |
|---------|-------------|
| `make list-artifacts` | List built artifacts |
| `make clean` | Clean local artifacts |
| `make clean-remote` | Clean remote artifacts |
| `make watch-build` | Monitor build progress |
| `make help` | Show all available commands |

## 🔍 Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clean and retry
make clean
make build-all

# Clean remote directories
make clean-remote

# Check connectivity (requires manual ansible command)
ansible docker_build -i inventory -m ping
```

#### Disk Space Issues
```bash
# Check artifact size and list files
make list-artifacts

# Clean old artifacts
make clean
```

#### Network Issues
```bash
# Check proxy settings in group_vars/all.yml
# Verify GitHub access from build hosts manually
```

### Log Locations
- **Ansible Logs**: Console output with `-v` flags
- **Docker Build Logs**: Container build output
- **Build Artifacts**: `artifacts/` directory

### Debug Mode
```bash
# Verbose Ansible output
ansible-playbook -i inventory playbooks/build.yml -v -e build_app=all

# Extra verbose
ansible-playbook -i inventory playbooks/build.yml -vvv -e build_app=go
```

## 🏗️ Extending the Project

### Adding New Components
1. Update `group_vars/all.yml` with new app configuration
2. Create Dockerfile template in `templates/`
3. Add new target to Makefile following existing pattern:
   ```makefile
   .PHONY: build-newapp
   build-newapp: ## Build new application
       @echo "$(BLUE)Building newapp...$(NC)"
       ansible-playbook -i $(INVENTORY) $(PLAYBOOK_DIR)/build.yml -e build_app=newapp
       @echo "$(GREEN)newapp build completed successfully$(NC)"
   ```

### Adding New Go Versions
1. Add version to `go.versions` in `group_vars/all.yml`
2. Ensure sequential ordering (each builds with previous)
3. Update app configurations to use new Go version

### Custom Build Environments
1. Modify Dockerfile templates in `templates/`
2. Add build-specific variables in `group_vars/`
3. Test with development inventory

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes with `make dry-run`
4. Submit a pull request

### Development Guidelines
- Test all changes with manual Ansible runs first
- Update documentation for new features
- Follow Ansible best practices
- Ensure Docker templates are secure
- Add new build targets to Makefile when adding components

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Kubernetes project for excellent build documentation
- Go team for consistent build processes
- Container runtime maintainers for clear build instructions

---

**Built with ❤️ for the Kubernetes community**