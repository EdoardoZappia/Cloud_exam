# Set up a Docker image based on Debian Bullseye, 
# install the necessary packages for building C++ code with Open MPI,
# clean up any temporary files created during the installation process to reduce the image size.
FROM debian:bullseye as builder

RUN apt update \
    && apt install -y --no-install-recommends \
        g++ \
        libopenmpi-dev \
        make \
    && rm -rf /var/lib/apt/lists/*
