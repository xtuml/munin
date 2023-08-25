FROM rockylinux:9

# metadata
LABEL org.opencontainers.image.source https://github.com/xtuml/munin

# copy installation
COPY build /work/build
COPY full_deploy /work/full_deploy

# set up entrypoint
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

# set working directory
WORKDIR /root

# copy configuration
COPY config /root/config
COPY schedule /root/schedule
