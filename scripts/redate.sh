for file in $marks ; do
  old_date=${file%-*}
  old_date=${old_date%-*}
  old_date=${old_date%-*}
  old_date=${old_date%.*}
  current=$(date +%y%m%d)
  time=$(date -r ${file} +%H%M%S)
  timed_date="${old_date}${time}"
  new_date=$(date -j -f "%y%m%d%H%M%S" ${timed_date} +%Y-%m-%d%H:%M:%S)
  touch -d ${new_date} ${file}
  file=${file%.*}
  echo "${file} | date: ${new_date}"
done
cd ../../scripts