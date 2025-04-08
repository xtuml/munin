FROM chainguard/glibc-dynamic:latest-dev AS build-env

RUN mkdir -p /home/nonroot/InvariantStore/

FROM chainguard/glibc-dynamic:latest

COPY /staging /

WORKDIR /home/nonroot

COPY --from=build-env --chown=nonroot /home/nonroot/InvariantStore/ /home/nonroot/InvariantStore/

ENV LD_LIBRARY_PATH=/apps/istore_proc/lib
ENV SASL_PATH=/apps/istore_proc/lib

ENTRYPOINT ["/apps/istore_proc/bin/ISTORE_PROC_sqlite"]
