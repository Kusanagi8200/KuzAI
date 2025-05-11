#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root  


/usr/local/bin/ollama ps | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g'

case "$1" in
    list)
        ollama list | awk 'NR>1 {print $1}'
        ;;
    run)
        ollama run "$2" > /dev/null 2>&1 &
        echo "$2 started"
        ;;
    stop)
        ollama stop "$2"
        echo "$2 stopped"
        ;;
    status)
        model_name="$2"
        ps aux | grep "ollama" | grep "$model_name" | grep -v grep > /dev/null
        if [ $? -eq 0 ]; then
            echo "running"
        else
            echo "stopped"
        fi
        ;;
    *)
        echo "Unknown action"
        ;;
esac
