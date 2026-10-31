# syntax=docker/dockerfile:1

ARG MINARCA_VERSION=7.2.0
# Unit tests include disk discovery that fails in containers with no block devices.
# Default off for local Docker builds; set RUN_TESTS=1 to force them.
ARG RUN_TESTS=0

#-----------------------------------------------------
# Build the arm64 .deb from the official minarca tag
#-----------------------------------------------------
FROM python:3.12-bookworm AS builder

ARG MINARCA_VERSION
ARG RUN_TESTS
ENV DEBIAN_FRONTEND=noninteractive
ENV SETUPTOOLS_SCM_PRETEND_VERSION_FOR_MINARCA_CLIENT=${MINARCA_VERSION}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential debhelper dpkg-dev \
      librsync-dev libacl1-dev libattr1-dev \
      python3-dev python3-pip python3-venv \
      git xvfb xauth cron zenity kdialog desktop-file-utils \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone --depth 1 --branch "${MINARCA_VERSION}" https://gitlab.com/ikus-soft/minarca.git minarca

WORKDIR /src/minarca

# GitHub runners (and this image) often have no D-Bus session.
RUN sed -i "s|NO_DBUS = not os.environ.get('DBUS_SESSION_BUS_ADDRESS', False)|NO_DBUS = True|" \
      minarca_client/core/notification/tests/test_notification.py

# debian/rules always runs py3-linux after build; skip that in containers by default.
RUN if [ "${RUN_TESTS}" != "1" ]; then \
      sed -i 's|^\t\$(TOX) -e py3-linux|\t@echo "Skipping unit tests in container (set RUN_TESTS=1 to enable)"|' debian/rules ; \
    fi

RUN dpkg-buildpackage -b -us -uc && \
    mkdir -p /out && \
    mv /src/minarca-client_*_arm64.deb "/out/minarca-client_${MINARCA_VERSION}_arm64.deb"

#-----------------------------------------------------
# Install the .deb and smoke-test
#-----------------------------------------------------
FROM debian:bookworm-slim AS test

ARG MINARCA_VERSION
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /out/minarca-client_${MINARCA_VERSION}_arm64.deb /tmp/minarca-client.deb

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates cron openssh-client && \
    apt-get install -y /tmp/minarca-client.deb && \
    rm -rf /var/lib/apt/lists/* /tmp/minarca-client.deb && \
    minarca --version

CMD ["minarca", "--version"]

#-----------------------------------------------------
# Export only the .deb (use with: docker build -o dist ...)
#-----------------------------------------------------
FROM scratch AS export
ARG MINARCA_VERSION
COPY --from=builder /out/minarca-client_${MINARCA_VERSION}_arm64.deb /
