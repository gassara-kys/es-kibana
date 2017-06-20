#!/bin/bash

if [ ${#} -ne 2 ]; then
  echo "Usage: ${0} 'yyyymmddhh' 'path/to/dir'" 1>&2;
  exit 1;
fi

YEAR=${1:0:4}
MONTH=${1:4:2}
DAY=${1:6:2}
HOUR=${1:8:2}
log_dir=${2}

echo -e "`date "+%Y/%m/%d %H:%M:%S"`: Downloed... ${YEAR}/${MONTH}/${DAY}_${HOUR} ->  $log_dir"

for file in `aws --profile ${S3_PROFILE} s3 ls \
          s3://${S3_HOST}/${S3_BASE_PATH}/${YEAR}/${MONTH}/${DAY}/ \
          | awk '{print $4}'  \
          | grep ${YEAR}${MONTH}${DAY}T${HOUR} `; do
    echo ${file} ;
    aws --profile ${S3_PROFILE} s3 cp s3://${S3_HOST}/${S3_BASE_PATH}/${YEAR}/${MONTH}/${DAY}/${file} ${log_dir} > /dev/null 2>&1;
done

echo -e "`date "+%Y/%m/%d %H:%M:%S"`: download done!"

exit 0;
