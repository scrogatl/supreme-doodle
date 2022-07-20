FROM python:3.10-slim-bullseye as base

FROM base as builder

RUN apt update && apt install git python3-pip -y
RUN apt install bash curl -y
RUN apt autoremove

FROM base

WORKDIR /
# Copy app and setup requirements
EXPOSE 5001
COPY hello /hello
WORKDIR /hello

# setup app requirements
RUN pip3 install -r requirements.txt

CMD flask run --host=0.0.0.0 -p 5001
