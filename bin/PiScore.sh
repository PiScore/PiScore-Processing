#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

clear
sleep 1
echo "$(cat $DIR/../LICENSE-SHORT)"
sleep 2
echo ""
echo "System IP address information:"
ifconfig | grep 'inet addr:'
echo ""
echo "Launching PiScore in 5 seconds..."
echo "(Ctrl + C to cancel)"
sleep 5
