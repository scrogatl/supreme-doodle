FROM python:3.10-slim-bullseye 

# FROM base AS builder

# RUN apt update && apt install git python3-pip -y
# RUN apt install bash -y
# RUN apt autoremove

# FROM base

WORKDIR /frontend

COPY frontend/requirements.txt /frontend/requirements.txt
RUN pip3 install -r requirements.txt

RUN apt update
RUN apt install procps net-tools curl -y
EXPOSE 5000

ENV NEW_RELIC_APP_NAME=doodle-frontend
# ENV OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true
# ENV OTEL_SERVICE_NAME=frontend
# ENV OTEL_RESOURCE_ATTRIBUTES=service.instance.id=19-4-6
# ENV OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true
# ENV OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp.nr-data.net
# ENV OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT=4095
# ENV OTEL_EXPORTER_OTLP_COMPRESSION=gzip
# ENV OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf 
# ENV OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=delta

# RUN opentelemetry-bootstrap -a install

COPY frontend/src/ /frontend
CMD newrelic-admin run-program flask run --host=0.0.0.0 -p 5000
# CMD flask run --host=0.0.0.0 -p 5000
# CMD opentelemetry-instrument --logs_exporter otlp flask run --debugger --host=0.0.0.0 -p 5000