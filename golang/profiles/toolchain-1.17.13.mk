PF_VERSION    = 1.17.13
PF_DOCKERFILE = Dockerfile.toolchain
PF_DEPS       = golang:1.17.13

PF_TEST_CMD = sh -c '\
	echo "=== go version ===" && \
	go version && \
	echo "=== go env ===" && \
	echo "GOROOT=$$GOROOT" && \
	echo "GOPATH=$$GOPATH" && \
	echo "=== tools ===" && \
	gcc --version | head -1 && \
	git --version && \
	make --version | head -1 && \
	pkg-config --version && \
	echo "" && echo "golang toolchain-1.17.13: ok"'
