FROM codercom/code-server:latest

USER root

# Install development packages
RUN apt-get update && \
    apt-get install -y \
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
    wget \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Add after the main apt-get install
RUN apt-get update && \
    apt-get install -y \
    libreadline-dev libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev \
    libbz2-dev libffi-dev zlib1g-dev && \
    wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tar.xz && \
    tar -xf Python-3.11.9.tar.xz && \
    cd Python-3.11.9 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.11.9 Python-3.11.9.tar.xz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Install Go 1.25.3 for ARM64
RUN wget -O go.tar.gz https://go.dev/dl/go1.25.3.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV GOROOT=/usr/local/go
ENV GOPATH=/home/coder/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

RUN mkdir -p $GOPATH/src $GOPATH/bin $GOPATH/pkg && \
    chown -R coder:coder $GOPATH

USER coder

# Install extensions available on Open VSX
RUN code-server --install-extension eamodio.gitlens && \
    code-server --install-extension golang.go && \
    code-server --install-extension franneck94.c-cpp-runner && \
    code-server --install-extension jbenden.c-cpp-flylint && \
    code-server --install-extension llvm-vs-code-extensions.vscode-clangd && \
    code-server --install-extension redhat.vscode-yaml && \
    code-server --install-extension streetsidesoftware.code-spell-checker && \
    code-server --install-extension twxs.cmake && \
    code-server --install-extension vadimcn.vscode-lldb && \
    code-server --install-extension xaver.clang-format

# Install Kylin IDE extensions (if available on Open VSX)
RUN code-server --install-extension kylinideteam.cmake-intellisence || true && \
    code-server --install-extension kylinideteam.cppdebug || true && \
    code-server --install-extension kylinideteam.kylin-clangd || true && \
    code-server --install-extension kylinideteam.kylin-cmake-tools || true && \
    code-server --install-extension kylinideteam.kylin-cpp-pack || true && \
    code-server --install-extension kylinideteam.kylin-debug || true

# Download and manually install Microsoft C/C++ extensions
RUN mkdir -p /tmp/extensions

RUN wget -O /tmp/extensions/cpptools.vsix \
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cpptools/latest/vspackage" && \
    code-server --install-extension /tmp/extensions/cpptools.vsix || true

RUN wget -O /tmp/extensions/cpptools-themes.vsix \
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cpptools-themes/latest/vspackage" && \
    code-server --install-extension /tmp/extensions/cpptools-themes.vsix || true

RUN wget -O /tmp/extensions/cmake-tools.vsix \
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cmake-tools/latest/vspackage" && \
    code-server --install-extension /tmp/extensions/cmake-tools.vsix || true

RUN wget -O /tmp/extensions/makefile-tools.vsix \
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/makefile-tools/latest/vspackage" && \
    code-server --install-extension /tmp/extensions/makefile-tools.vsix || true

RUN wget -O /tmp/extensions/hexeditor.vsix \
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/hexeditor/latest/vspackage" && \
    code-server --install-extension /tmp/extensions/hexeditor.vsix || true

RUN rm -rf /tmp/extensions

# Verify installations
RUN go version && gcc --version && clang --version
