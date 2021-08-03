#! /usr/bin/env sh
# main_script.sh

trap "echo 'caught exit signal'; exit 1" SIGHUP SIGINT SIGTERM

while true
  do sleep 1
done