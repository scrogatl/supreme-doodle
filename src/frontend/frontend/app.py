from flask import Flask
import requests
import os

app = Flask(__name__)

@app.route("/")
def front_end():
    helloHost = os.environ.get('HELLO_HOST', "localhost")
    worldHost = os.environ.get('WORLD_HOST', "localhost")
    shard = os.environ.get('SHARD', "na")
    print("HELLO_HOST: " + helloHost)
    print("WORLD_HOST: " + worldHost)
    print("SHARD: " + shard)


    resH = requests.get('http://' + helloHost + ':5001')

    resW = requests.get('http://' + worldHost + ':5002')

    print("Hello status: " + str(resH.status_code))
    print("Hello text: " + resH.text)
    print("World status: " + str(resW.status_code))
    print("World text: " + resW.text)
    return "Frontend (" + shard + ") " + resH.text + ' ' + resW.text

@app.route("/hash")
def get_hash():
    return "<p>1234</p>"
