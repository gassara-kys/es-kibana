#!/bin/bash

PREFIX=".monitoring-es-2-"
if [ $1 ]; then
  PREFIX=$1
fi

OLDER_THAN=2
if [ $2 ]; then
  OLDER_THAN=$2
fi

FROM=`date +%Y%m%d --date "${OLDER_THAN} days ago"`
CURRENT_DATE=$FROM

while :
do
  INDEX=`date --date "${CURRENT_DATE}" "+$PREFIX%Y.%m.%d"`
  STATUS_CODE=`curl -LI -o /dev/null -w '%{http_code}' -s http://localhost:9200/${INDEX}`
  if [ $STATUS_CODE = "404" ]; then
    break
  fi

  # インデックス削除
  echo "Delete index http://localhost:9200/${INDEX}"
  curl -w'\n' -XDELETE "http://localhost:9200/${INDEX}"
  CURRENT_DATE=`date -d "$CURRENT_DATE 1 day ago" "+%Y%m%d"`

done

exit 0

