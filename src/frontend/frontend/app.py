from flask import Flask
import requests
import os
from datetime import datetime


app = Flask(__name__)

@app.route("/")
def front_end():
    helloHost = os.environ.get('HELLO_HOST', "localhost")
    worldHost = os.environ.get('WORLD_HOST', "localhost")
    shard = os.environ.get('SHARD', "na")
    timeString = datetime.now().strftime("%H:%M:%S.%f")[:-3]
    res = timeString + " - [frontend: " + shard + "] - "
    try:
        resH = requests.get('http://' + helloHost + ':5001')
        if resH.status_code >= 300:
            res += " hello status: " + str(resH.status_code) + " - " + resH.text + " - " + str(resH.headers)
        else:
            res += " hello status: " + str(resH.status_code) + " - " + resH.text 

        resW = requests.get('http://' + worldHost + ':5002')
        if resW.status_code >= 300:
            res += " | world status: " + str(resW.status_code) + " - " + resW.text + " - " + str(resW.headers)
        else:
            res += " | world status: " + str(resW.status_code) + " - " + resW.text 
    except Exception as e:
        res += repr(e)

    print (res)
        # print("Hello status: " + str(resH.status_code))
        # print("Hello text: " + resH.text)
        # print("World status: " + str(resW.status_code))
        # print("World text: " + resW.text)
    return res

@app.route("/hash")
def get_hash():
    return "<p>1234</p>"
