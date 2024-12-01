# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Maintainer information
LABEL maintainer="iskoldt-X"

# Set environment variables
ENV CONDA_DIR=/usr/local/conda \
    PATH=/usr/local/conda/bin:$PATH \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Copy requirements.txt first to leverage Docker cache
COPY requirements.txt /requirements.txt

# Install necessary packages, set timezone and locale, install Miniconda, create Conda environment, and install packages
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        locales \
        tzdata \
        wget \
        git \
        ca-certificates \
        build-essential \
        libpq-dev && \
    ln -fs /usr/share/zoneinfo/Europe/Oslo /etc/localtime && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
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
    $CONDA_DIR/bin/conda clean -afy && \
    /bin/bash -c "source $CONDA_DIR/etc/profile.d/conda.sh && \
        conda create -n gpcrdb python=3.8 -y && \
        conda install -n gpcrdb -c conda-forge rdkit numpy scipy scikit-learn numexpr 'libblas=*=*openblas' -y && \
        conda run -n gpcrdb pip install -r /requirements.txt && \
        conda run -n gpcrdb pip install git+https://github.com/rdkit/django-rdkit.git && \
        conda clean -afy"

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

# Activate the Conda environment by default
RUN echo "source $CONDA_DIR/etc/profile.d/conda.sh && conda activate gpcrdb" >> ~/.bashrc

# Set the default command to bash
CMD ["/bin/bash"]
