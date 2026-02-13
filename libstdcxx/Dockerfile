# Сборка libstdc++ из исходников GCC.
# Результат: /out — только .so файлы libstdc++ (runtime).
#   /out/usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.25  — основная библиотека
#   /out/usr/lib/x86_64-linux-gnu/libgcc_s.so.1        — GCC runtime
# Использование: COPY --from=libstdcxx:8.5.0-build /out / && ldconfig

ARG BASE_IMAGE=astra-linux:2.12

FROM ${BASE_IMAGE} AS builder

#### <toolchain-gcc:8.5.0:toolchain> ####

#### compilation ####
ARG LIBSTDCXX_VERSION=8.5.0

WORKDIR /build

COPY artifacts/src/gcc-${LIBSTDCXX_VERSION}.tar.xz /build/

RUN tar xJf gcc-${LIBSTDCXX_VERSION}.tar.xz \
 && rm gcc-${LIBSTDCXX_VERSION}.tar.xz

# Конфигурируем GCC полностью, но собираем ТОЛЬКО libstdc++
RUN mkdir build && cd build \
 && ../gcc-${LIBSTDCXX_VERSION}/configure \
      --prefix=/usr \
      --libdir=/usr/lib/x86_64-linux-gnu \
      --disable-bootstrap \
      --disable-multilib \
      --enable-languages=c,c++ \
 && make -j$(nproc) all-target-libstdc++-v3 \
 && make DESTDIR=/out install-target-libstdc++-v3

# GCC устанавливает target-библиотеки в lib64, перемещаем в Debian multiarch путь
RUN mkdir -p /stage/usr/lib/x86_64-linux-gnu \
 && cp -a /out/usr/lib/lib64/libstdc++.so* /stage/usr/lib/x86_64-linux-gnu/ \
 && cp -a /out/usr/lib/lib64/libgcc_s.so* /stage/usr/lib/x86_64-linux-gnu/ \
 && rm -rf /out && mv /stage /out \
 && cp -a /out/* / \
 && ldconfig \
 && rm -rf /build/*
#### compilation ####

# Финальный образ — только результат сборки.
FROM ${BASE_IMAGE}
COPY --from=builder /out /out
