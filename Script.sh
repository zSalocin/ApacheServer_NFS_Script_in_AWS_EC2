#!/bin/bash

# Specify the log file directory
LOG_DIR="/mnt/efs/logs/"

# Create a log file name with the current date
DATE=$(date +"%Y%m%d")
LOG_FILE=""
SERVER_STATUS=""
STATUS_POST=""

if systemctl is-active --quiet httpd; then
    SERVER_STATUS="online"
    LOG_FILE="log_${DATE}online.log"
    STATUS_POST="The Apache server is Online"
else
    SERVER_STATUS="offline"
    LOG_FILE="log_${DATE}offline.log"
    STATUS_POST="The Apache server is Offline"
fi

# Create the full path to the log file
FULL_PATH="$LOG_DIR$LOG_FILE"

# Create the log file if it doesn't exist
if [ ! -f "$FULL_PATH" ]; then
    touch "$FULL_PATH"
    chmod 777 "$FULL_PATH"
fi

# Add a new log entry to the respective log file
echo "$(date): Apache server : $SERVER_STATUS : $STATUS_POST" >> "$FULL_PATH"

# Display success message
echo "Log entry added successfully to $FULL_PATH."