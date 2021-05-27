FROM nicspalla/ubuntu_spack_gcc_openmpi-fabric_mkl:latest

LABEL maintainer="Nicola Spallanzani - nicola.spallanzani@nano.cnr.it - S3 centre, CNR-NANO"

WORKDIR /tmpdir

### YAMBO ###
ARG yambo_version=5.0.2
RUN . ${SPACK_ROOT}/share/spack/setup-env.sh && spack load openmpi && spack load intel-mkl \
 && wget https://github.com/yambo-code/yambo/archive/${yambo_version}.tar.gz -O yambo-${yambo_version}.tar.gz \
 && tar zxf yambo-${yambo_version}.tar.gz && cd yambo-${yambo_version} \
 && ./configure --enable-open-mp --enable-msgs-comps --enable-time-profile --enable-memory-profile --enable-par-linalg \
    --with-blas-libs="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -lgomp -lpthread -lm -ldl" \
    --with-lapack-libs="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -lgomp -lpthread -lm -ldl" \
 && make libxc fftw iotk && make hdf5 && make netcdf && make scalapack \
 && make -j4 yambo && make -j4 interfaces && make -j4 ypp \
 && mkdir -p /usr/local/yambo-${yambo_version}/lib \
 && cp -r bin /usr/local/yambo-${yambo_version}/. \
 && cp -r lib/external/*/*/lib/*.* /usr/local/yambo-${yambo_version}/lib/. \
 && cp -r lib/external/*/*/v*/serial/lib/*.* /usr/local/yambo-${yambo_version}/lib/. \
 && cd .. && rm -rf yambo-${yambo_version} yambo-${yambo_version}.tar.gz \
 && echo "PATH=/usr/local/yambo-${yambo_version}/bin:$PATH" >> ${SPACK_ROOT}/env.txt \
 && echo "LD_LIBRARY_PATH=/usr/local/yambo-${yambo_version}/lib:$LD_LIBRARY_PATH" >> ${SPACK_ROOT}/env.txt 

ENV PATH=/usr/local/yambo-${yambo_version}/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/yambo-${yambo_version}/lib:$LD_LIBRARY_PATH
