{% sql 'create_last_query_table' %}
CREATE TABLE IF NOT EXISTS bayesrest_last_query (id INTEGER PRIMARY KEY, query TEXT)
{% endsql %}

{% sql 'get_full_table' %}
SELECT *, _rowid_ FROM {{ table_name }}
{% endsql %}

{% sql 'get_last_query' %}
SELECT query
FROM bayesrest_last_query
LIMIT 1;
{% endsql %}

{% sql 'set_last_query' %}
INSERT OR REPLACE INTO bayesrest_last_query (id, query)
VALUES (1, ?);
{% endsql %}

{% sql 'drop_dependence_probability_table' %}
DROP TABLE IF EXISTS bayesrest_depprob
{% endsql %}

{% sql 'create_dependence_probability_table' %}
CREATE TABLE IF NOT EXISTS bayesrest_depprob
AS ESTIMATE DEPENDENCE PROBABILITY
FROM PAIRWISE VARIABLES OF {{ population|default('bayesrest_population') }}
{% endsql %}

{% sql 'select_dependence_probabilities' %}
SELECT name1, value
FROM bayesrest_depprob
WHERE name0 = {{ column_name|guards.string }}
ORDER BY value DESC
{% endsql %}

{% sql 'find_anomalies' %}
ESTIMATE
_rowid_,
PREDICTIVE PROBABILITY OF {{ target_column }}
{% if context_columns %}
  GIVEN ({{ context_columns|join(',') }})
{% endif %}
AS pred_prob
FROM {{ population|default('bayesrest_population') }}
ORDER BY pred_prob
{% endsql %}

{% sql 'find_peer_rows' %}
ESTIMATE _rowid_, SIMILARITY TO ("rowid" == {{ target_row|guards.integer }})
IN THE CONTEXT OF {{ context_column }} AS sim
FROM {{ population|default('bayesrest_population') }}
ORDER BY sim DESC
{% endsql %}

{% sql 'pairwise_similarity' %}
ESTIMATE SIMILARITY
IN THE CONTEXT OF {{ context_column }}
FROM PAIRWISE {{ population|default('bayesrest_population') }}
WHERE rowid0 in ({{ row_set }}) and rowid1 in ({{ row_set }})
{% endsql %}

{% sql 'column_data' %}
SELECT _rowid_, {{ column_names|join(',') }}
FROM {{ table_name }}
{% endsql %}

{% sql 'row_id_data' %}
SELECT _rowid_
FROM {{ table_name }}
{% endsql %}
