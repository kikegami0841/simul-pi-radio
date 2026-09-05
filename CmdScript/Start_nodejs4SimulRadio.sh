#!/bin/bash

# sleep 50
# sleep 10
sleep 5
# pid1 = $!
# wait $pid1
# /usr/bin/bash -x -c "cd $HOME/SimulRadio; DEBUG=SimulRadio:* npm start &"
cd $HOME/SimulRadio
DEBUG=SimulRadio:* /usr/bin/npm start &


