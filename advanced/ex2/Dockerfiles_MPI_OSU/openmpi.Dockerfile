# Build an image, updating the package lists, installing the openmpi-bin package, 
# and cleaning up the downloaded package lists to reduce the image size.
FROM mpioperator/base:latest

RUN apt update \
    && apt install -y --no-install-recommends openmpi-bin \
    && rm -rf /var/lib/apt/lists/*
