#! /usr/bin/env sh
# main_script.sh

trap "echo 'caught exit signal: SIGHUP'; exit 1" SIGHUP
trap "echo 'caught exit signal: SIGINT'; exit 1" SIGINT
trap "echo 'caught exit signal: SIGTERM'; exit 1" SIGTERM
trap "echo 'caught exit signal: SIGQUIT'; exit 1" SIGQUIT

while true
  do sleep 1
done
