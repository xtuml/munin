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

# copy schedules
ADD schedule /root/schedule

# create test directories
RUN mkdir -p /root/incoming /root/processing /root/processed

# configure the library path
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/install/lib

# add the install location to the path
ENV PATH=$PATH:/install/bin

# set the entrypoint
ENTRYPOINT ["/install/bin/AEO_SVDC_transient"]



################################################################################
# NORMAL BUILD                                                                   #
################################################################################

# build stage
FROM build-base AS build-release

# copy includes and libs from the domains
RUN mkdir -p /install/include
RUN mkdir -p /install/lib
COPY --from="ghcr.io/xtuml/aeordering" /install/include/ /install/include
COPY --from="ghcr.io/xtuml/aeordering" /install/lib/ /install/lib
COPY --from="ghcr.io/xtuml/aeordering" /install/share/ /install/share
COPY --from="ghcr.io/xtuml/istore" /install/include/ /install/include
COPY --from="ghcr.io/xtuml/istore" /install/lib/ /install/lib
COPY --from="ghcr.io/xtuml/aesequencedc" /install/include/ /install/include
COPY --from="ghcr.io/xtuml/aesequencedc" /install/lib/ /install/lib

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
