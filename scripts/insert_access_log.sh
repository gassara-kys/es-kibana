#!/bin/bash

# 環境変数
source `dirname ${0}`/config/env.sh

# 10時間前の値を取得
TEN_HOUR_AGO=`date -d "10 hour ago" "+%Y%m%d%H"`
log_dir=`dirname ${0}`/tmp

if [ -n "${1}" ]; then
  TEN_HOUR_AGO=${1}
fi

if [ -n "${2}" ]; then
  if [ ! -e `dirname ${0}`/${2} ]; then
    echo "`dirname ${0}`/${2} Not found!" 1>&2
    echo "Usage: ${0} 'yyyymmddhh' 'download_path_name'" 1>&2
    exit 1
  fi
  log_dir=`dirname ${0}`/${2}
fi

echo -e "`date "+%Y/%m/%d %H:%M:%S"`: Insert for ${TEN_HOUR_AGO} !"

rm -rf ${log_dir}
mkdir ${log_dir}

# download logs
`dirname ${0}`/lib/download_logs.sh \
    ${TEN_HOUR_AGO} \
    ${log_dir}
if [ $? -ne 0 ]; then echo "Download Error";exit 1; fi

# summary logs
`dirname ${0}`/lib/summary_by_ip.sh \
    ${TEN_HOUR_AGO} \
    ${log_dir}
if [ $? -ne 0 ]; then echo "Summary Error";exit 1; fi

# post logs
`dirname ${0}`/lib/put_logs.sh \
    ${TEN_HOUR_AGO} \
    ${log_dir}
if [ $? -ne 0 ]; then echo "Post Error";exit 1; fi

# send slack
`dirname ${0}`/lib/noti_slack.sh \
    ${log_dir}
if [ $? -ne 0 ]; then echo "Slack Error";exit 1; fi

exit 0;
