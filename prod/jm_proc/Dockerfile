FROM chainguard/glibc-dynamic:latest

COPY /staging /

WORKDIR /home/nonroot

ENV LD_LIBRARY_PATH=/apps/jm_proc/lib
ENV SASL_PATH=/apps/jm_proc/lib
ENV JSON_META_SCHEMA_PATH=/apps/jm_proc/config/json-metaschema.json
ENV JM_CONFIG_SCHEMA_PATH=/apps/jm_proc/schema/jm_config_schema.json

ENTRYPOINT ["/apps/jm_proc/bin/JM_PROC_transient"]
