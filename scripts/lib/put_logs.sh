#!/bin/bash

if [ ${#} -ne 2 ]; then
  echo "Usage: ${0} 'yyyymmddhh' 'path/to/dir'" 1>&2;
  exit 1;
fi
DAY=${1:0:8}
TIME=${1:8:2}
log_dir=${2}

# インデックス作成(作成済みならスルー)
#ES_INDEX=${ES_INDEX_PRE}${DAY}_${TIME}
ES_INDEX=${ES_INDEX_PRE}${DAY}

STATUS_CODE=`curl -LI -o /dev/null -w '%{http_code}' -s http://${ES_HOST}:${ES_PORT}/${ES_INDEX}`
echo -e "`date "+%Y/%m/%d %H:%M:%S"`: INDEX_STATUS=${STATUS_CODE}"
if [ ${STATUS_CODE} != "200" ]; then
  echo -e "`date '+%Y/%m/%d %H:%M:%S'`: create index http://${ES_HOST}:${ES_PORT}/${ES_INDEX}"
  curl -XPUT http://${ES_HOST}:${ES_PORT}/${ES_INDEX}/
  curl -XPUT http://${ES_HOST}:${ES_PORT}/${ES_INDEX}/_mapping/${ES_TYPE} -d @${log_dir}/../config/${ES_TYPE}.json
fi

# whois情報付与(時間かかりすぎるので上位100まで)
echo -e "\n`date "+%Y/%m/%d %H:%M:%S"`: check whois info & format json."
BULK_IDX='{"index" : {}}'
#date="${DAY}_${TIME}+0900";
date="${DAY}_${TIME}+0000";
other_cnt=0;
idx=0;
IFS=$'\n'
for line in `cat ${log_dir}/summary_ip_${DAY}_${TIME}.txt`; do

  idx=$(($idx+1));
  cnt=`echo ${line} | awk '{print $1}'`;

  # 上位10000万位以下のレコードは"other"としてサマル
  if [ ${idx} -gt 10000 ]; then
    other_cnt=$(($other_cnt+$cnt));
    continue;
  fi

  ipaddr=`echo ${line} | awk '{print $2}'`;
  if [ ${idx} -lt 100 ]; then
    netname=`timeout 10s whois -h whois.apnic.net ${ipaddr} | grep netname -m 1 | sed -E "s/^netname: +//g"`;
    country=`timeout 10s whois -h whois.apnic.net ${ipaddr} | grep country -m 1 | sed -E "s/^country: +//g"`;
    if [[ ${country} = "JP" ]]; then
      organization=`timeout 10s whois -h whois.nic.ad.jp ${ipaddr} | grep Organization -m 1 | sed -E "s/^g\. \[Organization\] +//g"`;
    else
      organization=`timeout 10s whois -h whois.apnic.net ${ipaddr} | grep descr -m 1 | sed -E "s/^descr: +//g"`;
    fi
  else
    netname="";
    country="";
    organization="";
  fi

  json_data='{"date":"'${date}'", "ip":"'${ipaddr}'", "count":"'${cnt}'", "netname":"'${netname}'", "contry":"'${country}'", "organization":"'${organization}'"}';
  echo -e "${BULK_IDX}\n${json_data}" >> ${log_dir}/bulk_insert.json;

done;

# other
json_data='{"date":"'${date}'", "ip":"other", "count":"'${other_cnt}'", "netname":"", "contry":""}';
echo -e "${BULK_IDX}\n${json_data}" >> ${log_dir}/bulk_insert.json;


# bulk api
echo -e "`date "+%Y/%m/%d %H:%M:%S"`: post to elasticsearch by bulk api!"
curl -s -XPOST http://${ES_HOST}:${ES_PORT}/${ES_INDEX}/${ES_TYPE}/_bulk --data-binary @${log_dir}/bulk_insert.json > /dev/null 2>&1 ;

exit 0;
