################################################################################
# DOMAIN IMAGES                                                                #
################################################################################
ARG VERSION_TAG=latest
FROM ghcr.io/xtuml/aeordering:${VERSION_TAG} as aeordering
FROM ghcr.io/xtuml/freception:${VERSION_TAG} as freception
FROM ghcr.io/xtuml/aereception:${VERSION_TAG} as aereception
FROM ghcr.io/xtuml/istore:${VERSION_TAG} as istore
FROM ghcr.io/xtuml/aesequencedc:${VERSION_TAG} as aesequencedc

################################################################################
# BASE BUILD                                                                   #
################################################################################

FROM levistarrett/masl-base:v4.0.0-beta2 AS build-base

ARG EXTRA_MASL_ARGS=

# set the working directory
WORKDIR /build

# copy sources
ADD masl /root/masl
ADD CMakeLists.txt /root/CMakeLists.txt


################################################################################
# BASE INSTALL                                                                 #
################################################################################

FROM levistarrett/masl-base:v4.0.0-beta2 AS install-base

# copy schedules
ADD schedule /root/schedule

# create test directories
RUN mkdir -p /root/incoming /root/processed

# configure the library path
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/install/lib:/opt/cppkafka/lib:/opt/rdkafka/lib

# add the install location to the path
ENV PATH=$PATH:/install/bin

# set the entrypoint
ENTRYPOINT ["/install/bin/PV_PROC_transient"]



################################################################################
# NORMAL BUILD                                                                   #
################################################################################

# build stage
FROM build-base AS build-release

# copy includes and libs from the domains
RUN mkdir -p /install/include
RUN mkdir -p /install/lib
COPY --from=aeordering /install/include/ /install/include
COPY --from=aeordering /install/lib/ /install/lib
COPY --from=aeordering /install/share/ /install/share
COPY --from=aereception /install/include/ /install/include
COPY --from=aereception /install/lib/ /install/lib
COPY --from=aereception /install/share/ /install/share
COPY --from=freception /install/include/ /install/include
COPY --from=freception /install/lib/ /install/lib
COPY --from=freception /install/share/ /install/share
COPY --from=istore /install/include/ /install/include
COPY --from=istore /install/lib/ /install/lib
COPY --from=aesequencedc /install/include/ /install/include
COPY --from=aesequencedc /install/lib/ /install/lib

# perform the build
RUN cmake /root -G Ninja -DEXTRA_MASL_ARGS="${EXTRA_MASL_ARGS}" -DCMAKE_INSTALL_PREFIX=/install
RUN ninja install

# installation stage
FROM install-base AS install-release

LABEL org.opencontainers.image.source https://github.com/xtuml/munin

# copy the libs and bins
COPY --from=build-release /install/bin /install/bin
COPY --from=build-release /install/lib /install/lib
COPY --from=build-release /install/share /install/share

# copy in the MASL interfaces
RUN mkdir -p /install/lib/masl
COPY --from=build-release /root/masl/**/*.int /install/lib/masl

