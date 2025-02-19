from flask import Flask
from flask import request
from datetime import datetime

import os
import logging

log = logging.getLogger('werkzeug')
log.setLevel(logging.DEBUG)

app = Flask(__name__)

shard = os.environ.get('SHARD', "SHARD_NOT_SET")
ecs_cmd = os.environ.get("ECS_CONTAINER_METADATA_URI_V4", "NOT_SET")

def logit(message):
    timeString = datetime.now().strftime("%H:%M:%S.%f")[:-3]
    log.info(timeString + " - [world: " + shard + "] - " + message)
    print(timeString + " - [world: " + shard + "] - " + message)


@app.route("/")
def hello_world():
    print("SHARD: " + shard )
    logit("SHARD: " + shard )
    return "World (" + shard + "), ECS_CONTAINER_METADATA_URI_V4: " + ecs_cmd
