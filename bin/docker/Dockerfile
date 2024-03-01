ARG MASL_VERSION

FROM levistarrett/masl-dev:${MASL_VERSION}

ARG MASL_VERSION

ARG MUNIN_VERSION

LABEL org.opencontainers.image.source="https://github.com/xtuml/munin"

ENV MASL_VERSION=${MASL_VERSION}

RUN conan install --requires=pv_proc/${MUNIN_VERSION}@xtuml/stable --deployer=full_deploy

COPY --chmod=751 entrypoint.sh /entrypoint.sh

WORKDIR /root

ENTRYPOINT ["/entrypoint.sh"]
