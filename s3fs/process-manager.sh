#! /usr/bin/env sh

# Define the processes
first_process=empty.sh
second_process=${SECOND_ENTRYPOINT}
echo $second_process

forward_signals() {
  SIGNAL=$1
  echo "Caught $SIGNAL!, forwarding"
  # Forward to process1
  if [ -n "$process1" ]; then
      echo "Forwarding $SIGNAL to $first_process"
      kill -$SIGNAL $process1
  fi
  # Forward to process2
  if [ -n "$process2" ]; then
    # This is to allow alternate signals for the second process
    if [ -n "${SECOND_STOPSIGNAL}" ]; then
      if [ $SIGNAL -e TERM]; then
        echo "Changing TERM to ${SECOND_STOPSIGNAL} and forwarding to $second_process"
        kill -"${SECOND_STOPSIGNAL}" $process2
      fi
    fi
      echo "Forwarding $SIGNAL to $second_process"
      kill -$SIGNAL $process2
  fi
}

trap "forward_signals INT" INT
trap "forward_signals TERM" TERM
trap "forward_signals QUIT" QUIT

# Start the first process
${first_process} >/dev/null 2>&1
status=$?
process1=$! ${first_process}
if [ $status -ne 0 ]; then
  echo "Failed to start ${first_process}: $status"
  exit $status
fi

# Start the second process if it has been specified
if [ -n "${SECOND_ENTRYPOINT}" ]; then
  echo "starting second process: ${second_process}"
  ${second_process} >/dev/null 2>&1
  status=$?
  process2=$! ${second_process}
  if [ $status -ne 0 ]; then
    echo "Failed to start ${second_process}: $status"
    exit $status
  fi
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

while sleep 60; do
  ps aux | grep "${first_process}" | grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux | grep "${second_process}" | grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # Exit if either process is not found
  if [ $PROCESS_1_STATUS -ne 0]; then
    echo "${first_process} has already exited."
    exit 1
  fi
  # Check whether there is a second process that should be running and if so make sure it is still up
  if [ -n "${SECOND_ENTRYPOINT}"]; then
    if [ $PROCESS_2_STATUS -ne 0]; then
      echo "${second_process} has already exited."
      exit 1
    fi
  fi
done
