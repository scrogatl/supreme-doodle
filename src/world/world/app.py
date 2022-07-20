from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "World"

@app.route("/hash")
def get_hash():
    return "<p>1234</p>"
