#!//bin/bash

MAX_CNT=`cat $1/summary_ip_*.txt | head -n 1|awk '{print $1}'`
IP_ADDR=`cat $1/summary_ip_*.txt | head -n 1|awk '{print $2}'`
PER_SECOND=$(($MAX_CNT/3600))

if [ $PER_SECOND -gt 150 ] ; then
  MSG_TXT="【危険！】$IP_ADDR から秒間 $PER_SECONDぺろんちょされてます > $SLACK_URL_LINK";

  curl_content="payload={\"channel\":\"${SLACK_NOTI_CHANNEL}\",\"username\":\™${SLACK_USER_NAME}\™,\"icon_emoji\":\":innocent:\",\"text\": "
  curl_content="${curl_content}${MSG_TXT}"
  curl_content="${curl_content}\"}"
  curl="curl -X POST --data-urlencode `echo -e "'${curl_content}'"` https://hooks.slack.com/services/${SLACL_HOOK_KEY}"
  eval $curl

fi

#9000000
TOTAL_CNT=`cat $1/summary_ip_*.txt | awk '{sum+=$1}END{print sum}'`;

if [ $TOTAL_CNT -gt 9000000 ] ; then
  MSG_TXT="【警戒！】合計 $TOTAL_CNTぺろんちょ/時を確認したYO > $SLACK_URL_LINK";
  curl_content="payload={\"channel\":\"${SLACK_NOTI_CHANNEL}\",\"username\":\™${SLACK_USER_NAME}\™,\"icon_emoji\":\":innocent:\",\"text\": "
  curl_content="${curl_content}${MSG_TXT}"
  curl_content="${curl_content}\"}"
  curl="curl -X POST --data-urlencode `echo -e "'${curl_content}'"` https://hooks.slack.com/services/${SLACL_HOOK_KEY}"
  eval $curl
fi
