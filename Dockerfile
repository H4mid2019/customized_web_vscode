FROM codercom/code-server:latest

USER root

# Install all development packages in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # C/C++ development tools
    build-essential \
    gdb \
    manpages-dev \
    cmake \
    git \
    valgrind \
    clang \
    clang-format \
    clangd \
    lldb \
    # General utilities
    wget \
    curl \
    # Python build dependencies
    libreadline-dev \
    libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    libffi-dev \
    zlib1g-dev \
    # Additional useful tools
    vim \
    nano \
    htop && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3.14.0 from source
# Note: --enable-optimizations disabled for ARM64 to avoid build timeouts and OOM errors
# Profile-guided optimization (PGO) is very resource-intensive on ARM architecture
RUN wget https://www.python.org/ftp/python/3.14.0/Python-3.14.0.tar.xz && \
    tar -xf Python-3.14.0.tar.xz && \
    cd Python-3.14.0 && \
    ./configure && \
    make -j$(nproc) altinstall && \
    cd .. && \
    rm -rf Python-3.14.0 Python-3.14.0.tar.xz && \
    # Create symlinks for easier access
    ln -s /usr/local/bin/python3.14 /usr/local/bin/python3 && \
    ln -s /usr/local/bin/python3.14 /usr/local/bin/python && \
    ln -s /usr/local/bin/pip3.14 /usr/local/bin/pip3 && \
    ln -s /usr/local/bin/pip3.14 /usr/local/bin/pip

# Upgrade pip and install common Python packages
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir \
    pylint \
    autopep8 \
    black \
    flake8 \
    pytest \
    mypy \
    requests \
    numpy

# Install Go 1.25.1 for ARM64 (latest stable as of October 2025)
RUN wget -O go.tar.gz https://go.dev/dl/go1.25.1.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Set Go environment variables
ENV GOROOT=/usr/local/go
ENV GOPATH=/home/coder/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

# Create Go workspace directories
RUN mkdir -p $GOPATH/src $GOPATH/bin $GOPATH/pkg && \
    chown -R coder:coder $GOPATH

# Install common Go tools
RUN go install golang.org/x/tools/gopls@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest && \
    go install honnef.co/go/tools/cmd/staticcheck@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    chown -R coder:coder $GOPATH

# Switch to coder user
USER coder

# Install Python extensions from Open VSX (code-server's default registry)
RUN code-server --install-extension ms-python.python || true && \
    code-server --install-extension wholroyd.jinja || true && \
    code-server --install-extension donjayamanne.python-environment-manager || true

# Install Go extensions from Open VSX
RUN code-server --install-extension golang.go || true

# Install C/C++ extensions from Open VSX
# Note: Microsoft C/C++ extensions may not be available on Open VSX
# Using open-source alternatives that work with code-server
RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd || true && \
    code-server --install-extension xaver.clang-format || true && \
    code-server --install-extension twxs.cmake || true && \
    code-server --install-extension vadimcn.vscode-lldb || true && \
    code-server --install-extension franneck94.c-cpp-runner || true

# Install general development extensions from Open VSX
RUN code-server --install-extension eamodio.gitlens || true && \
    code-server --install-extension redhat.vscode-yaml || true && \
    code-server --install-extension streetsidesoftware.code-spell-checker || true

# Switch back to root for verification
USER root

# Verify installations and display versions
RUN echo "=== Verifying installations ===" && \
    go version && \
    gcc --version | head -n1 && \
    clang --version | head -n1 && \
    python3 --version && \
    pip3 --version && \
    cmake --version | head -n1 && \
    git --version && \
    echo "=== Go tools ===" && \
    ls -la $GOPATH/bin/ || echo "No Go tools installed" && \
    echo "=== All installations verified ==="

# Switch back to coder user for runtime
USER coder

# Set working directory
WORKDIR /home/coder/project
