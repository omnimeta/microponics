import sys
import os
import flask
import sqlite3
from flask import Flask, url_for

class SQLDatabase:

    def __init__(self, filepath):
        self.filepath = filepath
        self.db = None
        try:
            self.db = sqlite3.connect(filepath)
            if not isinstance(self.db, sqlite3.Connection):
                raise Exception('Failed to open connection to database with path \'%s\'' % self.filepath)
        except Exception as err:
            print('Error: %s' % str(err))
            if isinstance(self.db, sqlite3.Connection):
                self.db.close()
            raise err # propagate error outwards


    def close(self):
        if isinstance(self.db, sqlite3.Connection):
            self.db.close()


    def setup_tables(self):
        self._create_plants_table_if_not_exists()
        self._create_readings_table_if_not_exists()


    def _create_plants_table_if_not_exists(self):
        self._create_db_table("""CREATE TABLE IF NOT EXISTS plants (
            id integer PRIMARY KEY,
            node TEXT,
            pod TEXT,
            name TEXT
        );""")


    def _create_readings_table_if_not_exists(self):
        self._create_db_table("""CREATE TABLE IF NOT EXISTS readings (
            id INTEGER PRIMARY KEY,
            node TEXT,
            pod TEXT,
            timestamp INTEGER,
            temperature TEXT,
            light_on INTEGER,
            ph REAL,
            ppm REAL
        );""")


    def _create_db_table(self, create_sql):
        try:
            cursor = self.db.cursor()
            cursor.execute(create_sql)
        except sqlite3.Error as err:
            print('Error: %s' % str(err))
            print('Failed to create table using SQL \'%s\'' % create_sql)
            raise err
