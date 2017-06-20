#!/bin/bash

if [ ${#} -ne 2 ]; then
  echo "Usage: ${0} 'yyyymmddhh' 'path/to/dir'" 1>&2;
  exit 1;
fi
DAY=${1:0:8}
TIME=${1:8:2}
log_dir=${2}

echo -e "`date "+%Y/%m/%d %H:%M:%S"`: summary access count by ip per hour. (day:${DAY} hour:${TIME})"
gzip -dc ${log_dir}/*_${DAY}T${TIME}*.log.gz \
        | awk -F" " '{print $4}' \
        | sed -e "s/:.*$//g" \
        | sort \
        | uniq -c \
        | sort -n -r \
        > ${log_dir}/summary_ip_${DAY}_${TIME}.txt ;

echo -e "`date "+%Y/%m/%d %H:%M:%S"`: summary done."
exit 0;
