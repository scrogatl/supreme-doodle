FROM python:3.10-slim-bullseye as base

FROM base as builder

RUN apt update && apt install git python3-pip -y
RUN apt install bash -y
RUN apt autoremove

FROM base

WORKDIR /world

COPY world/requirements.txt /world/requirements.txt
RUN pip3 install -r requirements.txt

ENV OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true
ENV OTEL_SERVICE_NAME=world
ENV OTEL_RESOURCE_ATTRIBUTES=service.instance.id=19-4-23-02
ENV OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true
ENV OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT=4095
ENV OTEL_EXPORTER_OTLP_COMPRESSION=gzip
ENV OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=delta
ENV PYTHONUNBUFFERED=1

RUN opentelemetry-bootstrap -a install

COPY world/src/ /world

EXPOSE 5002

ENV NEW_RELIC_APP_NAME=doodle-world

CMD newrelic-admin run-program flask run --host=0.0.0.0 -p 5002
# CMD flask run --host=0.0.0.0 -p 5002
# CMD opentelemetry-instrument --logs_exporter otlp flask run --debugger --host=0.0.0.0 -p 5002

