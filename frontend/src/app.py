import os
from flask import Flask, url_for, render_template

APP = Flask(__name__)
STORAGE_ADDR = 'http://%s:%s' % (os.environ['MICROPONICS_STORAGE_SERVICE_HOST'],
                                 os.environ['MICROPONICS_STORAGE_SERVICE_PORT'])

@APP.route('/', methods=[ 'GET' ])
def homepage():
    return render_template('index.html')


@APP.route('/health', methods=[ 'GET' ])
def healthcheck():
    return 'Serving'


if __name__ == '__main__':
    APP.run(host='0.0.0.0', port=8080)
