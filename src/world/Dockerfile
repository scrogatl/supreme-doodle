FROM python:3.10-slim-bullseye as base

FROM base as builder

RUN apt update && apt install git python3-pip -y
RUN apt install bash curl -y
RUN apt autoremove

FROM base

WORKDIR /
# Copy app and setup requirements
EXPOSE 5002
COPY world /world
WORKDIR /world

# setup app requirements
RUN pip3 install -r requirements.txt

CMD flask run --host=0.0.0.0 -p 5002
