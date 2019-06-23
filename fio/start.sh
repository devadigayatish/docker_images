#!/bin/bash

export JOB_NAME=${JOB_NAME:-fio}
export NJ=${NJ:-16}
export QD=${QD:-16}
export BLOCK_SIZE=${BLOCK_SIZE:-4k}
export DIR=${DIR:-/data}
export DIRECT=${DIRECT:-1}
export RW=${RW:-write}
export RT=${RT:-300}

# If DIR contains multiple directories, calculating size for each directory.
# Each directory may be of different size
DIR_LIST=($(echo $DIR | tr ":" "\n"))
JOB_STRING=" "

for (( i = 0; i < ${#DIR_LIST[@]}; i++))
do
    # Obtaining size of the mounted directory in which files will be created
    dir_size_in_MBytes=`df -TBM ${DIR_LIST[$i]} | awk 'NR==2' | awk '{print $5}'`
    dir_size_int=${dir_size_in_MBytes/%M/}
  
    # Calculating available size for each fio job
    available_size_per_job=`expr ${dir_size_int} / ${NJ}`M

    # Generating job for each directory dynamically depending on available space
    JOB_STRING+=" --name=job$i --size=$available_size_per_job --directory=${DIR_LIST[$i]}"
done

# In case of rw=read, we will first write on the entire device before reading from it
if [[ "$RW" == *read* ]]
then
	/usr/bin/fio --ioengine=libaio --rw=write --fill_device=1 --fill_fs=1 --iodepth=32 --bs=512K --numjobs=$NJ --group_reporting $JOB_STRING
fi

exec /usr/bin/fio --ioengine=libaio --rw=${RW} --numjobs=${NJ} --direct=${DIRECT} --bs=${BLOCK_SIZE} --iodepth=${QD} --runtime=${RT} --time_based=1 --group_reporting --eta-newline=1s --output /data/${JOB_NAME}.out $JOB_STRING



