# Customized Web VS Code for Development

A Docker image based on code-server with pre-installed development tools for Go, C/C++, and Python.

## Features

### Languages & Tools Installed

- **Go 1.25.1** with tools:
  - gopls (Language server)
  - dlv (Delve debugger)
  - staticcheck (Linter)
  - goimports (Import formatter)

- **C/C++ Development**:
  - GCC & G++
  - Clang & LLVM
  - GDB & LLDB debuggers
  - CMake
  - Valgrind
  - clang-format, clangd

- **Python 3.14.0** with packages:
  - pylint, flake8 (Linters)
  - black, autopep8 (Formatters)
  - pytest (Testing)
  - mypy (Type checking)
  - numpy, requests (Common libraries)

### VS Code Extensions

Code-server uses the Open VSX registry. The following extensions are pre-installed:

- **Python**: ms-python.python, wholroyd.jinja, donjayamanne.python-environment-manager
- **Go**: golang.go
- **C/C++**: llvm-vs-code-extensions.vscode-clangd, xaver.clang-format, twxs.cmake, vadimcn.vscode-lldb, franneck94.c-cpp-runner
- **General**: eamodio.gitlens, redhat.vscode-yaml, streetsidesoftware.code-spell-checker

### Pre-configured Settings

- Dark theme enabled by default
- Auto-save after 1 second
- Bracket pair colorization
- Python interpreter set to /usr/local/bin/python3.14
- Go language server enabled
- C/C++ IntelliSense configured for detected architecture

## Build Instructions

The Dockerfile automatically detects the system architecture (ARM64 or AMD64) and downloads the appropriate binaries.

```bash
docker build -t my-code-server .
```

Build time: 15-30 minutes due to compiling Python from source.

## Running the Container

### Basic Usage
```bash
docker run -it --name vscode \
  -p 8080:8080 \
  -v "${PWD}:/home/coder/project" \
  -e PASSWORD=yourpassword \
  custom-vscode:latest
```

Then access code-server at: `http://localhost:8080`

### With Persistent Extensions and Settings
```bash
docker run -it --name vscode \
  -p 8080:8080 \
  -v "${PWD}:/home/coder/project" \
  -v vscode-data:/home/coder/.local/share/code-server \
  -e PASSWORD=yourpassword \
  custom-vscode:latest
```

### Without Password (Not recommended for production)
```bash
docker run -it --name vscode \
  -p 8080:8080 \
  -v "${PWD}:/home/coder/project" \
  -e PASSWORD="" \
  custom-vscode:latest --auth none
```

## Verification

After building, verify installations:

```bash
docker run --rm my-code-server go version
docker run --rm my-code-server python3 --version
docker run --rm my-code-server gcc --version
```

## Environment Variables

- GOROOT=/usr/local/go
- GOPATH=/home/coder/go
- PATH includes Go binaries and Go tools

## Customization

### Adding More Python Packages
Edit the Dockerfile and add packages to the pip install command:
```dockerfile
RUN pip3 install --no-cache-dir \
    existing-package \
    your-new-package
```

### Adding More VS Code Extensions
Add more extension install commands:
```dockerfile
RUN code-server --install-extension publisher.extension-name || true
```

### Changing Go Version

Update the version number in the download URL (check https://go.dev/dl/ for available versions):

```dockerfile
RUN wget -O go.tar.gz https://go.dev/dl/go1.XX.X.linux-arm64.tar.gz && \
```

### Changing Python Version

Update the version number in the Python download URL (check https://www.python.org/downloads/ for available versions):

```dockerfile
RUN wget https://www.python.org/ftp/python/3.XX.X/Python-3.XX.X.tar.xz && \
```

**Note:** Remember to update all references to the version number including symlinks.

## Troubleshooting

### Extensions not appearing

Code-server uses the Open VSX registry, not Microsoft Marketplace. Some Microsoft extensions like Pylance and ms-vscode.cpptools are not available. Open-source alternatives are pre-installed.

### Go not found in integrated terminal

If go command is not found in the code-server terminal, rebuild the image. The latest version adds Go paths to .bashrc and .profile.

### Python not found

Use /usr/local/bin/python3.14 directly if the python3 symlink is not working.

### Python build fails

Python is compiled without --enable-optimizations to avoid build timeouts on ARM64 systems.

### Build is slow

Python compilation from source takes 15-30 minutes. This is normal.

## Architecture Support

The Dockerfile automatically detects the build architecture (ARM64 or AMD64) and configures itself accordingly. No manual changes needed.

Tested on: Ubuntu ARM64, Ubuntu AMD64

## Technical Details

| Component | Version |
|-----------|---------|
| Go | 1.25.1 |
| Python | 3.14.0 |
| Base Image | code-server:latest |

### Build Notes

- Python compiled without PGO optimizations for faster builds
- Go tools installed: gopls, dlv, staticcheck, goimports
- Extensions from Open VSX registry only

## License

This project builds upon [code-server](https://github.com/coder/code-server) which is licensed under the MIT License.
