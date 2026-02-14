PF_VERSION    = 13.2.0
PF_DOCKERFILE = Dockerfile.toolchain
PF_DEPS       = gcc:13.2.0

PF_TEST_CMD = sh -c '\
	echo "=== gcc version ===" && \
	gcc --version | head -1 && \
	echo "=== g++ version ===" && \
	g++ --version | head -1 && \
	echo "=== tools ===" && \
	make --version | head -1 && \
	cmake --version | head -1 && \
	pkg-config --version && \
	echo "" && echo "gcc toolchain-13.2.0: ok"'
