#!/bin/sh  

STATION=$1
STATUS=$2

case $STATUS in
  0)
	systemctl --user stop   ch_$STATION.service
	;;
  1)
	systemctl --user start  ch_$STATION.service
	;;
  99)
	systemctl --user disable ch_$STATION.service
	;;
  98)
	systemctl --user status ch_$STATION.service
	;;
esac

echo ":" $1 ":" $2 ":"

exit 0
