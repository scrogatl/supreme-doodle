FROM python:3.10-slim-bullseye as base

FROM base as builder

RUN apt update && apt install git python3-pip -y
RUN apt install bash -y
RUN apt autoremove

FROM base

WORKDIR /world

COPY world/requirements.txt /world/requirements.txt
RUN pip3 install -r requirements.txt

COPY world/src/ /world

EXPOSE 5002
CMD flask run --host=0.0.0.0 -p 5002
