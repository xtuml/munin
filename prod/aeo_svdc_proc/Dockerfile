FROM chainguard/glibc-dynamic:latest

COPY /staging /

WORKDIR /home/nonroot

ENV LD_LIBRARY_PATH=/apps/aeo_svdc_proc/lib
ENV SASL_PATH=/apps/aeo_svdc_proc/lib
ENV JSON_META_SCHEMA_PATH=/apps/aeo_svdc_proc/config/json-metaschema.json
ENV JOB_DEFINITION_SCHEMA_PATH=/apps/aeo_svdc_proc/schema/job_definition_schema.json
ENV ORDERING_CONFIG_SCHEMA_PATH=/apps/aeo_svdc_proc/schema/ordering_config_schema.json
ENV AUDIT_EVENT_SCHEMA_PATH=/apps/aeo_svdc_proc/schema/audit_event_schema.json

ENTRYPOINT ["/apps/aeo_svdc_proc/bin/AEO_SVDC_PROC_transient"]
