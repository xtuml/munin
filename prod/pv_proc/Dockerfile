FROM chainguard/glibc-dynamic:latest

LABEL org.opencontainers.image.source="https://github.com/xtuml/munin"

COPY /staging /

WORKDIR /home/nonroot

ENV LD_LIBRARY_PATH=/apps/pv_proc/lib
ENV SASL_PATH=/apps/pv_proc/lib
ENV JSON_META_SCHEMA_PATH=/apps/pv_proc/config/json-metaschema.json
ENV JM_CONFIG_SCHEMA_PATH=/apps/pv_proc/schema/jm_config_schema.json
ENV JOB_DEFINITION_SCHEMA_PATH=/apps/pv_proc/schema/job_definition_schema.json
ENV ORDERING_CONFIG_SCHEMA_PATH=/apps/pv_proc/schema/ordering_config_schema.json
ENV AUDIT_EVENT_SCHEMA_PATH=/apps/pv_proc/schema/audit_event_schema.json
ENV FILE_RECEPTION_CONFIG_SCHEMA_PATH=/apps/pv_proc/schema/file_reception_config_schema.json

ENTRYPOINT ["/apps/pv_proc/bin/PV_PROC_transient"]
