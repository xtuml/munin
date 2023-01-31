################################################################################
# BASE BUILD                                                                   #
################################################################################

FROM levistarrett/masl-base:v2 AS build-base

ARG EXTRA_MASL_ARGS=

# set the working directory
WORKDIR /build

# copy sources
ADD masl /root/masl
ADD CMakeLists.txt /root/CMakeLists.txt



################################################################################
# BASE INSTALL                                                                 #
################################################################################

FROM levistarrett/masl-base:v2 AS install-base

# copy config and schedules
ADD config /root/config
ADD schedule /root/schedule

# set up test folders
RUN mkdir -p /root/test-files/generated /root/test-files/incoming

# configure the library path
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/install/lib

# add the install location to the path
ENV PATH=$PATH:/install/bin

# set the entrypoint
ENTRYPOINT ["/install/bin/AESimulator_transient_standalone"]



################################################################################
# NORMAL BUILD                                                                   #
################################################################################

# build stage
FROM build-base AS build-release

# perform the build
RUN cmake /root -G Ninja -DEXTRA_MASL_ARGS="${EXTRA_MASL_ARGS}" -DCMAKE_INSTALL_PREFIX=/install
RUN ninja install

# installation stage
FROM install-base AS install-release

LABEL org.opencontainers.image.source https://github.com/xtuml/munin

# copy the includes, libs, and bins
COPY --from=build-release /install/include /install/include
COPY --from=build-release /install/lib /install/lib
RUN mkdir -p /install/bin
COPY --from=build-release /build/cmake-masl/build/AESimulator_OOA/AESimulator_transient_standalone /install/bin

# copy in the MASL interfaces
RUN mkdir -p /install/lib/masl
COPY --from=build-release /root/masl/**/*.int /install/lib/masl
