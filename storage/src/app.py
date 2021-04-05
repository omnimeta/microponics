import sys
import os
import json
from flask import Flask, jsonify, Response, url_for
from src.database import SQLDatabase

APP = Flask(__name__)
DB = None

# ----- Liveness/Health Routes ----- #

@APP.route('/', methods=[ 'GET' ])
def ping():
  return 'Ready'

# ----- Plant Routes ----- #

@APP.route('/plants', methods=[ 'GET' ])
def get_plants():
    return jsonify(DB.get_plants())

@APP.route('/plants/get', methods=[ 'GET' ])
def get_plant():
    return jsonify(DB.get_plant())

@APP.route('/plants/add', methods=[ 'POST' ])
def add_plant():
    return Response(json.dump(DB.add_plant()), status=201, mimetype='application/json')

@APP.route('/plants/delete', methods=[ 'DELETE' ])
def delete_plant():
    DB.delete_plant()
    return 'Deleted'

@APP.route('/plants/update', methods=[ 'PUT' ])
def update_plant():
    return jsonify(DB.update_plant())

# ----- Readings Routes ----- #

@APP.route('/readings', methods=[ 'GET' ])
def latest_plant_readings():
    return jsonify(DB.latest_readings())

@APP.route('/reading/add', methods=[ 'GET' ])
def add_reading():
    return jsonify(DB.add_reading())


# ----- Helper Functions ----- #

def setup_db():
    global APP
    global DB

    try:
        if 'DB_FILE' not in os.environ.keys() or os.environ['DB_FILE'] == '':
            raise Exception('No database file given - environment variable \'DB_FILE\' is not set')
        DB = SQLDatabase(os.environ['DB_FILE'])
    except Exception as err:
        if isinstance(DB, SQLDatabase):
            DB.close()
        raise err # propagate exception outwards
    else:
        DB.setup_tables()

# ----- Start Server ----- #

if __name__ == '__main__':
    try:
        setup_db()
        if not isinstance(DB, SQLDatabase):
            raise Exception('Failed to setup database connection')
        APP.run(host='0.0.0.0', port=8080)

    except Exception as err:
        print('Error: %s' % str(err))
        sys.exit(1)
    else:
      print('Terminating service')
      sys.exit(0)

    finally:
        if isinstance(DB, SQLDatabase):
            DB.close()
