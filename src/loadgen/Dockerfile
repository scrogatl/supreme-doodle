FROM python:3.10-slim-bullseye as base

FROM base as builder

RUN apt update && apt install git python3-pip -y
RUN apt install bash -y
RUN apt autoremove

FROM base

WORKDIR /
EXPOSE 5000
COPY loadgen /loadgen
WORKDIR /loadgen

# setup app requirements
RUN pip3 install -r requirements.txt

CMD python3 app.py
