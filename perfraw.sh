#!/usr/bin/env sh
set -e

if [ -z $DBENCH_MOUNTPOINT ]; then
    DBENCH_MOUNTPOINT=/fiovol
fi

if [ -z $FIO_SIZE ]; then
    FIO_SIZE=240G
    FIO_SIZE2=60G
fi

if [ -z $FIO_OFFSET_INCREMENT ]; then
    FIO_OFFSET_INCREMENT=25%
fi

if [ -z $FIO_DIRECT ]; then
    FIO_DIRECT=1
fi

if [ -z $FIO_SYNC ]; then
    FIO_SYNC=0
fi

echo Working dir: $DBENCH_MOUNTPOINT
echo


    echo Testing Read IOPS...
    echo 1 > /proc/sys/vm/drop_caches
    READ_IOPS=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=read_iops --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randread --time_based --ramp_time=10s --runtime=30s)
    echo "$READ_IOPS"
    READ_IOPS_VAL=$(echo "$READ_IOPS"|grep -E 'read ?:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Write IOPS...
    echo 1 > /proc/sys/vm/drop_caches
    WRITE_IOPS=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=write_iops --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randwrite --time_based --ramp_time=10s --runtime=30s)
    echo "$WRITE_IOPS"
    WRITE_IOPS_VAL=$(echo "$WRITE_IOPS"|grep -E 'write:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Read Bandwidth...
    echo 1 > /proc/sys/vm/drop_caches
    READ_BW=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=read_bw --filename=$DBENCH_MOUNTPOINT/fiotest --bs=128K --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randread --time_based --ramp_time=10s --runtime=30s)
    echo "$READ_BW"
    READ_BW_VAL=$(echo "$READ_BW"|grep -E 'read ?:'|grep -Eoi 'BW=[0-9GMKiBs/.]+'|cut -d'=' -f2)
    echo
    echo

    echo Testing Write Bandwidth...
    echo 1 > /proc/sys/vm/drop_caches
    WRITE_BW=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=write_bw --filename=$DBENCH_MOUNTPOINT/fiotest --bs=128K --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randwrite --time_based --ramp_time=10s --runtime=30s)
    echo "$WRITE_BW"
    WRITE_BW_VAL=$(echo "$WRITE_BW"|grep -E 'write:'|grep -Eoi 'BW=[0-9GMKiBs/.]+'|cut -d'=' -f2)
    echo
    echo

    if [ "$DBENCH_QUICK" == "" ] || [ "$DBENCH_QUICK" == "no" ]; then
        echo Testing Read Latency...
        echo 1 > /proc/sys/vm/drop_caches
        READ_LATENCY=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --name=read_latency --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=4 --size=$FIO_SIZE --readwrite=randread --time_based --ramp_time=10s --runtime=30s)
        echo "$READ_LATENCY"
        READ_LATENCY_VAL=$(echo "$READ_LATENCY"|grep ' lat.*avg'|grep -Eoi 'avg=[0-9.]+'|cut -d'=' -f2)
        echo
        echo

        echo Testing Write Latency...
        echo 1 > /proc/sys/vm/drop_caches
        WRITE_LATENCY=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --name=write_latency --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4K --iodepth=4 --size=$FIO_SIZE --readwrite=randwrite --time_based --ramp_time=10s --runtime=30s)
        echo "$WRITE_LATENCY"
        WRITE_LATENCY_VAL=$(echo "$WRITE_LATENCY"|grep ' lat.*avg'|grep -Eoi 'avg=[0-9.]+'|cut -d'=' -f2)
        echo
        echo

        echo Testing Read Sequential Speed...
        echo 1 > /proc/sys/vm/drop_caches
        READ_SEQ=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=read_seq --filename=$DBENCH_MOUNTPOINT/fiotest --bs=1M --iodepth=4 --fdatasync=$FIO_SYNC --size=$FIO_SIZE2 --readwrite=read --time_based --ramp_time=10s --runtime=30s --thread --numjobs=4 --offset=0 --offset_increment=$FIO_OFFSET_INCREMENT)
        echo "$READ_SEQ"
        READ_SEQ_VAL=$(echo "$READ_SEQ"|grep -E 'READ:'|grep -Eoi '(aggrb|bw)=[0-9GMKiBs/.]+'|cut -d'=' -f2)
        echo
        echo

        echo Testing Write Sequential Speed...
        echo 1 > /proc/sys/vm/drop_caches
        WRITE_SEQ=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=write_seq --filename=$DBENCH_MOUNTPOINT/fiotest --bs=1M --iodepth=4 --fdatasync=$FIO_SYNC --size=$FIO_SIZE2 --readwrite=write --time_based --ramp_time=10s --runtime=30s --thread --numjobs=4 --offset=0 --offset_increment=$FIO_OFFSET_INCREMENT)
        echo "$WRITE_SEQ"
        WRITE_SEQ_VAL=$(echo "$WRITE_SEQ"|grep -E 'WRITE:'|grep -Eoi '(aggrb|bw)=[0-9GMKiBs/.]+'|cut -d'=' -f2)
        echo
        echo

        echo Testing Read/Write Mixed...
        echo 1 > /proc/sys/vm/drop_caches
        RW_MIX=$(fio --randrepeat=0 --verify=0 --ioengine=libaio --direct=$FIO_DIRECT --gtod_reduce=1 --name=rw_mix --filename=$DBENCH_MOUNTPOINT/fiotest --bs=4k --iodepth=16 --fdatasync=$FIO_SYNC --size=$FIO_SIZE --readwrite=randrw --rwmixread=75 --time_based --ramp_time=10s --runtime=30s)
        echo "$RW_MIX"
        RW_MIX_R_IOPS=$(echo "$RW_MIX"|grep -E 'read ?:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
        RW_MIX_W_IOPS=$(echo "$RW_MIX"|grep -E 'write:'|grep -Eoi 'IOPS=[0-9k.]+'|cut -d'=' -f2)
        echo
        echo
    fi

    echo All tests complete.
    echo
    echo ==================
    echo = Dbench Summary =
    echo ==================
    echo "Random Read/Write IOPS: $READ_IOPS_VAL/$WRITE_IOPS_VAL. BW: $READ_BW_VAL / $WRITE_BW_VAL"
    if [ -z $DBENCH_QUICK ] || [ "$DBENCH_QUICK" == "no" ]; then
        echo "Average Latency (usec) Read/Write: $READ_LATENCY_VAL/$WRITE_LATENCY_VAL"
        echo "Sequential Read/Write: $READ_SEQ_VAL / $WRITE_SEQ_VAL"
        echo "Mixed Random Read/Write IOPS: $RW_MIX_R_IOPS/$RW_MIX_W_IOPS"
    fi

    rm $DBENCH_MOUNTPOINT/fiotest
    exit 0
