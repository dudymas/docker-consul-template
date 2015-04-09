#!/bin/sh

date
echo "Sending HUP to nginx"
sv hup nginx
