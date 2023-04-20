FROM golang

RUN apt-get update && apt-get install -y libonig-dev

ADD https://github.com/fstab/grok_exporter/archive/refs/tags/v1.0.0.RC5.tar.gz grok_exporter.tgz
RUN tar xzf grok_exporter.tgz
WORKDIR grok_exporter-1.0.0.RC5
RUN go install .

ADD https://github.com/logstash-plugins/logstash-patterns-core/archive/refs/tags/v4.3.4.tar.gz logstash_patterns_core.tgz
RUN tar xzf logstash_patterns_core.tgz
RUN mkdir -p logstash-patterns-core/patterns && cp -r logstash-patterns-core-4.3.4/patterns/legacy/* logstash-patterns-core/patterns

CMD /go/bin/grok_exporter -config /etc/grok_exporter/config.yml
