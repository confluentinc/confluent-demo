Deploy ES, Kibana, ksqlDB

```bash
./deploy/50_cp_demo.sh
```

Do mapping things (see below)

Create source connector

Do ksql things

Create sink connector


`./tools/shell.sh`

```bash
ksql --config-file tls.properties https://ksqldb:8088
```

```sql

CREATE STREAM wikipedia WITH (kafka_topic='wikipedia.parsed', value_format='AVRO');
CREATE STREAM wikipediabot AS SELECT *, (length->new - length->old) AS BYTECHANGE FROM wikipedia WHERE bot = true AND length IS NOT NULL AND length->new IS NOT NULL AND length->old IS NOT NULL;
CREATE STREAM wikipedianobot AS SELECT *, (length->new - length->old) AS BYTECHANGE FROM wikipedia WHERE bot = false AND length IS NOT NULL AND length->new IS NOT NULL AND length->old IS NOT NULL;
CREATE TABLE wikipedia_count_gt_1 WITH (key_format='JSON') AS SELECT user, meta->uri AS URI, count(*) AS COUNT FROM wikipedia WINDOW TUMBLING (size 300 second) WHERE meta->domain = 'commons.wikimedia.org' GROUP BY user, meta->uri HAVING count(*) > 1;

```

tee mapping_count.json <<-'EOF'
{
    "order": 0,
    "version": 10000,
    "index_patterns": "wikipedia_count_gt_*",
    "settings": {
        "index": {
            "number_of_shards": 1,
            "number_of_replicas": 1,
            "refresh_interval": "10s",
            "codec": "best_compression"
        }
    },
    "mappings": {
        "properties": {
            "META": {
                "dynamic": true,
                "type": "object",
                "properties": {
                    "URI": {
                        "type": "keyword"
                    }
                }
            },
            "USER": {
                "type": "keyword"
            },
            "COUNT": {
                "type": "long"
            }
        }
    }
}
EOF

curl -X PUT -H 'content-type:application/json' -d @mapping_count.json "http://elasticsearch:9200/_template/wikipedia_count_gt?pretty"

tee mapping_bot.json <<-'EOF'
{
    "order": 0,
    "version": 10000,
    "index_patterns": "wikipediabot",
    "settings": {
        "index": {
            "number_of_shards": 1,
            "number_of_replicas": 1,
            "refresh_interval": "10s",
            "codec": "best_compression"
        }
    },
    "mappings": {
        "_source" : {
            "enabled" : true
        },
        "properties": {
            "BOT": {
                "type": "boolean"
            },
            "BYTECHANGE": {
                "type": "long"
            },
            "COMMENT": {
                "type": "text"
            },
            "ID": {
                "type": "keyword"
            },
            "LENGTH": {
                "dynamic": true,
                "type": "object",
                "properties": {
                    "NEW": {
                        "type": "long"
                    },
                    "OLD": {
                        "type": "long"
                    }
                }
            },
            "LOG_ACTION": {
                "type": "keyword"
            },
            "LOG_ACTION_COMMENT": {
                "type": "keyword"
            },
            "LOG_ID": {
                "type": "keyword"
            },
            "LOG_TYPE": {
                "type": "keyword"
            },
            "META": {
                "dynamic": true,
                "type": "object",
                "properties": {
                    "DOMAIN": {
                        "type": "keyword"
                    },
                    "DT": {
                        "type": "date"
                    },
                    "ID": {
                        "type": "keyword"
                    },
                    "REQUEST_ID": {
                        "type": "keyword"
                    },
                    "STREAM": {
                        "type": "keyword"
                    },
                    "URI": {
                        "type": "keyword"
                    }
                }
            },
            "MINOR": {
                "type": "boolean"
            },
            "NAMESPACE": {
                "type": "keyword"
            },
            "PARSEDCOMMENT": {
                "type": "keyword"
            },
            "PATROLLED": {
                "type": "boolean"
            },
            "REVISION": {
                "dynamic": true,
                "type": "object",
                "properties": {
                    "NEW": {
                        "type": "keyword"
                    },
                    "OLD": {
                        "type": "keyword"
                    }
                }
            },
            "SERVER_NAME": {
                "type": "keyword"
            },
            "SERVER_SCRIPT_PATH": {
                "type": "keyword"
            },
            "SERVER_URL": {
                "type": "keyword"
            },
            "TIMESTAMP": {
                "type": "long"
            },
            "TITLE": {
                "type": "keyword"
            },
            "TYPE": {
                "type": "keyword"
            },
            "USER": {
                "type": "keyword"
            },
            "WIKI": {
                "type": "keyword"
            }
        }
    }
}
EOF

curl -X PUT -H 'content-type:application/json' -d @mapping_bot.json "http://elasticsearch:9200/_template/wikipediabot?pretty"

curl -X POST "http://kibana:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@./pipeline/cp-demo.ndjson