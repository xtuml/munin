FROM levistarrett/masl-dev:latest

ARG MUNIN_VERSION

LABEL org.opencontainers.image.source="https://github.com/xtuml/munin"

RUN conan install --requires=pv_proc/${MUNIN_VERSION}@xtuml/stable --deployer=full_deploy

COPY --chmod=751 entrypoint.sh /entrypoint.sh

WORKDIR /root

ENTRYPOINT ["/entrypoint.sh"]
