# es-kibana

## 概要

- 下記の構成になってます
```
docker-compose
    └kibana          ・・・データ表示
    └elasticserch    ・・・データストア＆サーチエンジン
    └scripts         ・・・データ登録削除用スクリプト
```

## Elasticserch ＆ Kibana

### 起動

- 下記のコマンドを実行します
```bash
docker-compose up
```

### 確認

- 下記のURLでKibanaを確認
```
http://localhost/
```

- 下記のcurlでESに直接接続
```
curl -X GET http://localhost:9200/${ES_INDEX}
```


## scripts

- S3ログをダウンロードして、Elasticsearchに登録するサンプルスクリプトです
  - S3からダウンロード
  - データを集計
    - 容量をおさえるため、集計してからデータを入れてます
    - ※本来はLogstashやfluentdなどで、生ログをぶっこんで、集計はES側にまかせるべき

### 準備）env.shで接続情報など登録

- scripts/config/env.shを用意します。
- S3、ES、Slack通知の接続先情報を環境ごとに設定する必要があります
```bash
#!/bin/bash

# S3ログ
export S3_PROFILE=""
export S3_HOST=""
export S3_BASE_PATH=""

# Elasticsearch
export ES_HOST="localhost"
export ES_PORT="9200"
export ES_INDEX_PRE="logs_"
export ES_TYPE="access_log"

# Slack通知設定
export SLACK_URL_LINK=""
export SLACK_NOTI_CHANNEL=""
export SLACK_USER_NAME=""
export SLACL_HOOK_KEY=""
```

### 実行）insert_access_log.sh

- scriptを実行します
```bash
./insert_access_log.sh
```

### 補足）delete_monitoring_es_data.sh ／ delete_access_log.sh
