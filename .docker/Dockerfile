FROM buildpack-deps:bookworm AS build-env

ARG GCC_GIT=bfb9105ffbff952599ec949cee1e18ddc1f849ba
ARG LLVM_VERSION=20
ARG GDB_VERSION=15.1
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install dependencies
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends \
        abigail-tools \
        dpkg-dev \
        flex \
        gnupg \
        python3-dev \
        libgmp-dev \
        libmpfr-dev \
        unzip \
        ninja-build \
        zip \
        wget \
        lsb-release \
        software-properties-common \
        python3-pip \
        cmake-format; \
    rm -rf /var/lib/apt/lists/*

# Build GCC from source
RUN set -eux; \
    curl -fL https://github.com/gcc-mirror/gcc/archive/$GCC_GIT.zip -o gcc.zip; \
    unzip gcc.zip -d /usr/src && rm gcc.zip; \
    mv /usr/src/gcc-$GCC_GIT /usr/src/gcc; \
    cd /usr/src/gcc; \
    ./contrib/download_prerequisites; \
    mkdir -p build && cd build; \
    ../configure --disable-multilib --enable-languages=c,c++ --build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    make -j"$(nproc)"; \
    make install-strip; \
    cd / && rm -rf /usr/src/gcc

# Building CMake from sources
RUN set -ex; \
    curl -fL https://gitlab.kitware.com/cmake/cmake/-/archive/master/cmake-master.zip -o cmake.zip; \
    unzip cmake.zip -d /usr/src; \
    rm cmake.zip; \
    cd /usr/src/cmake-master; \
    ./bootstrap && make && make install; \
    rm -rf /usr/src/cmake-master

# Install GDB from source
RUN set -eux; \
    curl -fL https://ftp.gnu.org/gnu/gdb/gdb-$GDB_VERSION.tar.gz -o gdb.tar.gz; \
    tar -xf gdb.tar.gz -C /usr/src && rm gdb.tar.gz; \
    cd /usr/src/gdb-$GDB_VERSION; \
    ./configure --prefix=/usr/local --enable-tui --with-python; \
    make -j"$(nproc)" && make install; \
    cd / && rm -rf /usr/src/gdb-$GDB_VERSION

# Install LLVM (this assumes that llvm.sh will install based on LLVM_VERSION)
RUN set -eux; \
    curl -fL https://apt.llvm.org/llvm.sh -o llvm.sh; \
    chmod +x llvm.sh; \
    ./llvm.sh $LLVM_VERSION all || echo ""; \
    rm llvm.sh

# Install vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git /home/$USERNAME/vcpkg; \
    /home/$USERNAME/vcpkg/bootstrap-vcpkg.sh;

# Final image
FROM buildpack-deps:bookworm

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create user with sudo privileges
RUN set -eux; \
    groupadd --gid $USER_GID $USERNAME; \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; \
    apt-get update; \
    apt-get install -y sudo; \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME; \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Copy built tools from the build environment
COPY --from=build-env /usr/local /usr/local
COPY --from=build-env /home/$USERNAME/vcpkg /home/$USERNAME/vcpkg

# Ensure GDB avoids security checks and autoloads Python pretty-printing
RUN mkdir -p /home/$USERNAME/.config/gdb; \
    echo "set auto-load safe-path /" > /home/$USERNAME/.config/gdb/gdbinit

USER $USERNAME

# Set environment variables
ENV CC=/usr/local/bin/gcc
ENV VCPKG_ROOT=/home/$USERNAME/vcpkg
ENV PATH="${VCPKG_ROOT}:${PATH}"

# Clean up unnecessary packages and files
RUN set -eux; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*
