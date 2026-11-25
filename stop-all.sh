#!/bin/bash

if [ -d "logs" ]; then
    for pid_file in logs/*.pid; do
        if [ -f "$pid_file" ]; then
            pid=$(cat "$pid_file")
            echo "Stopping process $pid from $pid_file..."
            kill "$pid" 2>/dev/null
            rm "$pid_file"
        fi
    done
    echo "All services stopped."
else
    echo "No logs directory found."
fi
