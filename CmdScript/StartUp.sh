#!/bin/bash

#/usr/bin/sleep 7

/usr/bin/bash -c "/opt/simulradio/bin/Start_nodejs4SimulRadio.sh"

/usr/bin/sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080 

#/usr/bin/sleep 5

THRESHOLD="40"

WLANSTATUS=$(ip route | wc -c)
until [ $WLANSTATUS -gt $THRESHOLD ]
do
  sleep 5
  WLANSTATUS=$(ip route | wc -c)
done

echo 'END'
exit 0
