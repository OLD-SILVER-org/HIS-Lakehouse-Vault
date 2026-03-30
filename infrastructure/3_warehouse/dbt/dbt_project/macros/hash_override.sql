{% macro postgres__hash_alg_md5() -%}
    {# 
      Override automate_dv default which returns DECODE(MD5(...), 'hex') (bytea).
      We return UPPER(MD5(...)) as standard VARCHAR for easier readability in DBeaver/SQL.
    #}
    {% do return("UPPER(MD5([HASH_STRING_PLACEHOLDER]))") %}
{% endmacro %}
