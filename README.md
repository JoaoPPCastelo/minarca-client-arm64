# Introduction

This is a **non official** version of Minarca client built for ARM 64 devices like Raspberry Pi.

It is based on the code available on the [official repository](https://gitlab.com/ikus-soft/minarca) with minor changes in order to create an arm64 version of it, since there's no official package available.

# Installation
To install Minarca on your arm64 device, follow the steps below.
```bash
# Download the .deb package from GitHub
curl -L -o minarca-client-arm64.deb https://github.com/JoaoPPCastelo/minarca-client-arm64/releases/download/v1.0.1/minarca-client_6.1.0a3_arm64.deb

# Install the .deb package on your system
apt install -y ./minarca-client-arm64.deb

# Check the installation
minarca --version
```

# Configuration
To configure minarca, please check the [offical docs](https://nexus.ikus-soft.com/repository/archive/minarca/6.0.3/doc/minarca-client-cli.html).

# Bugs

It is possible that some issues exist with the provided package. This is on it's early stages and still testing the features as i use them. If you find any issue, feel free to [create an issue on GitHub](https://github.com/JoaoPPCastelo/minarca-client-arm64/issues).