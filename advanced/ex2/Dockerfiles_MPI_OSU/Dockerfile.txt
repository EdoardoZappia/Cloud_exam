# Create a container with the OSU Micro-Benchmarks installed, ready to be used 
# for performance testing and benchmarking MPI libraries.
FROM localhost/openmpi-builder as builder

RUN mkdir -p /osu

COPY --from=osu-code-provider /code/osu-micro-benchmarks-7.3 /osu

WORKDIR /osu

RUN ./configure CC=mpicc CXX=mpicxx --prefix=/usr/local/osu \
    && make \
    && make install

FROM localhost/openmpi as operator

COPY --from=builder /usr/local/osu /home/mpiuser/osu
