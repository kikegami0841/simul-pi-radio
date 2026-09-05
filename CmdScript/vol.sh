#!/bin/bash

echo "amixer sset Master $1%,$1% unmute" 

amixer sset Master "$1%","$1%" unmute

