from flask import Flask
import requests
from flask import request
import os
from datetime import datetime
from time import sleep
from random import randrange
import logging

log = logging.getLogger('werkzeug')
log.setLevel(logging.DEBUG)

app = Flask(__name__)

helloHost     = os.environ.get('HELLO_HOST', "localhost")
worldHost     = os.environ.get('WORLD_HOST', "localhost")
worldHostRuby = os.environ.get('WORLD_HOST_RUBY', "localhost")
worldPort     = os.environ.get('WPORT', "5002")
worldPortRuby = os.environ.get('WPORT_RUBY', "5002")
shard         = os.environ.get('SHARD', "na")
rubyWorld    = os.environ.get('RUBY_WORLD', "50")

def logit(message):
    timeString = datetime.now().strftime("%H:%M:%S.%f")[:-3]
    log.info(timeString + " - [frontend: " + shard + "] - " + message)
    print(timeString + " - [frontend: " + shard + "] - " + message)
    

# logit("worldHost: " + worldHost )
# logit("worldPort: " + worldPort)
# logit("worldHostRuby: " + worldHostRuby )
# logit("worldPortRuby: " + worldPortRuby)
# logit("rubyWorld: " + rubyWorld)
# logit( "initialized")

def generate_acct_num():
    r = randrange(10000)
    return str(r) 

def RUBY_WORLD():
    r = randrange(100)
    if r < int(rubyWorld):
        logit("world-ruby")
        return worldHostRuby, worldPortRuby
    else: 
        logit("world-python")
        return worldHost, worldPort

@app.route("/")
def front_end():
    httpStatus = 200
    logit("handling /")
    # logit("worldHost: " + worldHost )
    # logit("worldPort: " + worldPort)
    # logit("worldHostRuby: " + worldHostRuby )
    # logit("worldPortRuby: " + worldPortRuby)
    # logit("rubyWorld: " + rubyWorld)
    res = ""
    try:
        resH = requests.get('http://' + helloHost + ':5001' + "?account=" + generate_acct_num())
        httpStatus = resH.status_code
        res += "hello status: " + str(resH.status_code) + " - " + resH.text 
    except Exception as e:
        res += "hello status: " + repr(e)

    try: 
        lHost, lPort = RUBY_WORLD()
        logit(lHost + ":" + lPort)
        resW = requests.get('http://' + lHost + ':' + lPort)
        httpStatus = resW.status_code
        res += " | world status: " + str(resW.status_code) + " - " + resW.text 
    except Exception as e:
        httpStatus = 500
        res += " world status: " + repr(e)

    logit (res)
    return res,  httpStatus

