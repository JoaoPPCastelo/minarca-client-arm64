# Introduction

This is a **non official** GitHub build of the Minarca client for ARM64 devices like Raspberry Pi.

It is based on the code available on the [official repository](https://gitlab.com/ikus-soft/minarca). Upstream now also publishes official arm64 packages, so prefer those when you can. This project remains useful if you want a GitHub-hosted `.deb` built from a specific tag.

Current target version: **7.2.0**

# Build and test locally (Docker)

On macOS or Linux with Docker Buildx, you can build the arm64 `.deb` and smoke-test it in a container:

```bash
chmod +x build.sh
./build.sh          # defaults to 7.2.0
./build.sh 7.2.0    # explicit version
```

This will:
1. Build the Debian package from the official [minarca](https://gitlab.com/ikus-soft/minarca) tag
2. Write `dist/minarca-client_<VERSION>_arm64.deb`
3. Install that `.deb` in a clean Debian image and run `minarca --version`

Useful variants:

```bash
# Only export the .deb (skip the install smoke-test)
SKIP_TEST=1 ./build.sh 7.2.0

# Also run upstream unit tests during the package build
# (may fail in Docker because disk-discovery tests need real block devices)
RUN_TESTS=1 ./build.sh 7.2.0

# Or use docker buildx directly
docker buildx build --platform linux/arm64 \
  --build-arg MINARCA_VERSION=7.2.0 \
  --target export -o type=local,dest=./dist .

docker buildx build --platform linux/arm64 \
  --build-arg MINARCA_VERSION=7.2.0 \
  --target test --load -t minarca-client-arm64:7.2.0-test .

docker run --rm minarca-client-arm64:7.2.0-test
```

Note: the first build compiles with PyInstaller, so it can take several minutes. By default the Docker build skips upstream unit tests (disk discovery fails without block devices) and instead smoke-tests by installing the `.deb` and running `minarca --version`.

# Installation
To install Minarca on your arm64 device, follow the steps below.
```bash
# From a local Docker build
apt install -y ./dist/minarca-client_7.2.0_arm64.deb

# Or download from the latest GitHub release
# Replace <VERSION> with the release tag, e.g. v1.2.0
curl -L -o minarca-client-arm64.deb \
  https://github.com/JoaoPPCastelo/minarca-client-arm64/releases/download/<VERSION>/minarca-client_7.2.0_arm64.deb
apt install -y ./minarca-client-arm64.deb

# Check the installation
minarca --version
```

# Configuration
To configure minarca, please check the [official docs](https://minarca.org/).

# Bugs

If you find any issue, feel free to [create an issue on GitHub](https://github.com/JoaoPPCastelo/minarca-client-arm64/issues).
