from flask import Flask
import requests
import os

app = Flask(__name__)

@app.route("/")
def front_end():
    helloHost = os.environ.get('HELLO_HOST', "localhost")
    worldHost = os.environ.get('WORLD_HOST', "localhost")
    print("HELLO_HOST: " + helloHost)
    print("WORLD_HOST: " + worldHost)

    resH = requests.get('http://' + helloHost + ':5001')

    resW = requests.get('http://' + worldHost + ':5002')

    print(resH.status_code)
    print(resH.text)
    return resH.text + ' ' + resW.text

@app.route("/hash")
def get_hash():
    return "<p>1234</p>"
