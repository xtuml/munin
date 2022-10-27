################################################################################
# BASE BUILD                                                                   #
################################################################################

FROM levistarrett/masl-base:v1 AS build-base

ARG EXTRA_MASL_ARGS=

# set the working directory
WORKDIR /build

# copy sources
ADD masl /root/masl
ADD CMakeLists.txt /root/CMakeLists.txt



################################################################################
# BASE INSTALL                                                                 #
################################################################################

FROM levistarrett/masl-base:v1 AS install-base

# copy config and schedules
ADD schedule /root/schedule

# configure the library path
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/install/lib

# add the install location to the path
ENV PATH=$PATH:/install/bin

# set the entrypoint
ENTRYPOINT ["/install/bin/SequenceProcessor_transient_standalone"]



################################################################################
# TEST BUILD                                                                   #
################################################################################

# build stage
FROM build-base AS build-test

# perform the build
RUN cmake /root -G Ninja -DCMAKE_BUILD_TYPE=Debug -DEXTRA_MASL_ARGS="${EXTRA_MASL_ARGS}" -DCMAKE_INSTALL_PREFIX=/install
RUN ninja install

# installation stage
FROM install-base AS install-test

# copy the includes, libs, and bins
COPY --from=build-test /build /build
COPY --from=build-test /install/include /install/include
COPY --from=build-test /install/lib /install/lib
RUN mkdir -p /install/bin
COPY --from=build-test /build/cmake-masl/build/SequenceProcessor_OOA/SequenceProcessor_transient_standalone /install/bin



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
COPY --from=build-release /build/cmake-masl/build/SequenceProcessor_OOA/SequenceProcessor_transient_standalone /install/bin

# copy in the MASL interfaces
RUN mkdir -p /install/lib/masl
COPY --from=build-release /root/masl/**/*.int /install/lib/masl
