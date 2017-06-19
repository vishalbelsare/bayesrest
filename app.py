from flask import Flask, request
import bayeslite
from iventure.utils_bql import cursor_to_df
from bayesdb_flask import *

app = Flask(__name__)

app.debug = True

@app.route("/analyze", methods=['POST'])
def analyze():
	print(request.json)
	table_name = request.json['name'].decode('utf-8')
	data = request.json['data']
	bdb = create_bdb(table_name)
	sql_queries = [create_table(table_name, data), insert_values(table_name, data)]
	bql_queries = [create_population(table_name), create_metamodel(table_name),\
				initialize_models(table_name), analyze_metamodel(table_name)]
	for sq in sql_queries:
		with bdb.savepoint():
			bdb.sql_execute(sq)
	for bq in bql_queries:
		with bdb.savepoint():
			bdb.execute(bq)
	return "OK!"

@app.route("/query", methods=['GET'])
def query():
	query = simulate("some_name", "age")
	with bdb.savepoint():
		cursor = bdb.execute(query)
	return cursor_to_df(cursor).to_json()

# https://www.getpostman.com/apps

if __name__ == "__main__":
    app.run(host='localhost', port=5000)