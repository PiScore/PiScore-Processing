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
echo -ne "Launching PiScore in 5 seconds... (Ctrl + C to cancel)"\\r
sleep 1
echo -ne "Launching PiScore in 4 seconds... (Ctrl + C to cancel)"\\r
sleep 1
echo -ne "Launching PiScore in 3 seconds... (Ctrl + C to cancel)"\\r
sleep 1
echo -ne "Launching PiScore in 2 seconds... (Ctrl + C to cancel)"\\r
sleep 1
echo -ne "Launching PiScore in 1 seconds... (Ctrl + C to cancel)"\\r
sleep 1
echo "Launching PiScore..."
sleep 0.2
exec startx
