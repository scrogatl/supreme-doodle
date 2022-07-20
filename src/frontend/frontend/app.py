from flask import Flask
import urllib.request
import os

app = Flask(__name__)

@app.route("/")
def front_end():
    helloHost = os.environ.get('HELLO_HOST', "localhost")
    worldHost = os.environ.get('WORLD_HOST', "localhost")
    print("HELLO_HOST: " + helloHost)
    print("WORLD_HOST: " + worldHost)
    resH = urllib.request.urlopen(urllib.request.Request(
        url='http://' + helloHost + ':5001',
        headers={'Accept': 'application/text'},
        method='GET'), timeout=5)

    resW = urllib.request.urlopen(urllib.request.Request(
        url='http://' + worldHost + ':5001',
        headers={'Accept': 'application/text'},
        method='GET'), timeout=5)

    print(resH.status)
    print(resH.reason)
    resTextH = resH.read()
    print(resTextH) 
    print(type(resTextH))
    return resTextH.decode("utf-8") + " " + resW.read().decode("utf-8") 

@app.route("/hash")
def get_hash():
    return "<p>1234</p>"
