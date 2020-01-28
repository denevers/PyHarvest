#!/usr/bin/env python

import os
import json

from datetime import datetime
from flask import Flask, g, render_template, request, jsonify, Response
from crawler import crawl

app = Flask(__name__)

def format_datetime(value):
    local_time = datetime.fromtimestamp(value, tzlocal.get_localzone())
    return local_time.strftime("%b %d %Y %H:%M (%Z)")

@app.route("/")
def index():
    
    return render_template("index.html")

def shutdown_server():
    func = request.environ.get('werkzeug.server.shutdown')
    if func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    func()

# gracefully shutdown flask app server
@app.route('/shutdown', methods=['POST', 'GET'])
def shutdown():
    shutdown_server()
    return 'Server shutting down... bye.'

# get the status: running = true, not running = false
@app.route('/status', methods=['GET'])
def get_status():
    return json.dumps({'status':os.path.exists('static/run.lock')})

# initiate harvest task
@app.route('/harvest', methods=['POST', 'GET'])
def harvest():
    json = crawl()
    return Response(json, mimetype='application/json', status='HTTP_200_OK')

app.add_template_filter(format_datetime)
 
if __name__ == "__main__":
    app.run(debug=True)
