#!/bin/bash

set -e

SERVICE="$1"
ACTION="$2"

if [ $ACTION = "start" ]
then
    if ! sudo systemctl is-active --quiet "$SERVICE"
    then
        echo ""
        echo "Service [$SERVICE] is not running."
        sudo systemctl $ACTION "$SERVICE"
        echo "Service [$SERVICE] started successfully."
    fi

elif [ $ACTION = "stop" ]
then
    if sudo systemctl is-active --quiet "$SERVICE"
    then
        echo ""
        echo "Service [$SERVICE] is running."
        sudo systemctl $ACTION "$SERVICE".*
        echo "Service [$SERVICE] stopped successfully."
    fi
elif [ $ACTION = "restart" ]
then
    echo ""
    echo "Restarting service [$SERVICE]."
    sudo systemctl $ACTION "$SERVICE"
    echo "Service [$SERVICE] restarted successfully."

fi

