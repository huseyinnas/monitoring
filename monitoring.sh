#!/bin/bash

function send_notification {
    local recipient="huseyinnas2001@hotmail.com"
    local msmtp_config="/home/huseyin/.msmtprc"

    echo -e "Subject: System Resource Notification\n\n$1" | msmtp -a fixcloud $recipient
}

#-----------------------------------------------------#

# Internet Connection Check
ping -c 1 google.com &> /dev/null
if [ $? -ne 0 ]; then
    send_notification "Internet connection is not available."
fi

#-----------------------------------------------------#

# Docker Service Check
docker_status=$(systemctl is-active docker)
if [ "$docker_status" != "active" ]; then
    sudo systemctl start docker.service
    send_notification "Docker service is not running."
fi

# Status Check of Web Server and Database Containers
running_containers=$(docker ps --format "{{.Names}}")
web_server_status=$(echo "$running_containers" | grep -q "webserver" && echo "running" || echo "stopped")
database_server_status=$(echo "$running_containers" | grep -q "database" && echo "running" || echo "stopped")

if [ "$web_server_status" == "stopped" ]; then
    send_notification "Web server is not running."
fi

if [ "$database_server_status" == "stopped" ]; then
    send_notification "Database server is not running."
fi

#------------------------------------------------------#

# CPU Status Check
cpu_usage=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
if [ "$cpu_usage" -gt 80 ]; then
    send_notification "CPU usage is high: $cpu_usage%"
fi

# Disk Status Check
disk_usage=$(df -h | awk '$NF=="/"{print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 80 ]; then
    send_notification "Disk usage is high: $disk_usage%"
fi

# Disk Status Check
ram_usage=$(free | awk '/Mem/{printf "%.2f", $3/$2*100}')
if [ "$(echo "$ram_usage > 80" | bc -l)" -eq 1 ]; then
    send_notification "RAM usage is high: $ram_usage%"
fi
