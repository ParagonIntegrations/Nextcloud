#! /usr/bin/env sh

echo "Empty.sh started"
DEST=${AWS_S3_MOUNT:-/opt/s3fs/bucket}

exit_script() {
    SIGNAL=$1
    echo "Caught $SIGNAL! Unmounting ${DEST}..."
    fusermount -uz ${DEST}
    s3fs=$(ps -o pid= -o comm= | grep s3fs | sed -E 's/\s*(\d+)\s+.*/\1/g')
    if [ -n "$s3fs" ]; then
        echo "Forwarding $SIGNAL to $s3fs"
        kill -$SIGNAL $s3fs
    fi
    trap - $SIGNAL # clear the trap
    exit $?
}

trap "exit_script INT" SIGINT
trap "exit_script TERM" SIGTERM
trap "exit_script QUIT" SIGQUIT

echo "about to start tail"
tail -f /dev/null
