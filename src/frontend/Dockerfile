FROM python:3.10-slim-bullseye as base

FROM base as builder

RUN apt update && apt install git python3-pip -y
RUN apt install bash -y
RUN apt autoremove

FROM base
RUN apt update
RUN apt install bash curl  iputils-ping -y

WORKDIR /
# Copy app and setup requirements
EXPOSE 5000
COPY frontend /frontend
WORKDIR /frontend

# setup app requirements
RUN pip3 install -r requirements.txt

CMD flask run --host=0.0.0.0 -p 5000
