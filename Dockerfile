FROM ubuntu:22.04

# Author: iskoldt-X

# This Dockerfile is based on Ubuntu 22.04 and installs the latest Miniconda for x86_64 or aarch64 architectures.

LABEL maintainer="iskoldt-X"

# Install necessary packages
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libgl1 locales micro tzdata wget ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CONDA_DIR=/usr/local/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Download the appropriate Miniconda installer based on the architecture
RUN set -x && \
    UNAME_M="$(uname -m)" && \
    if [ "${UNAME_M}" = "x86_64" ]; then \
        MINICONDA=Miniconda3-latest-Linux-x86_64.sh; \
    elif [ "${UNAME_M}" = "aarch64" ]; then \
        MINICONDA=Miniconda3-latest-Linux-aarch64.sh; \
    else \
        echo "Unsupported architecture: ${UNAME_M}"; exit 1; \
    fi && \
    wget -q -O /tmp/$MINICONDA https://repo.anaconda.com/miniconda/$MINICONDA && \
    bash /tmp/$MINICONDA -b -p $CONDA_DIR && \
    rm /tmp/$MINICONDA && \
    $CONDA_DIR/bin/conda clean -afy

# Add a default command
CMD ["/bin/bash"]
