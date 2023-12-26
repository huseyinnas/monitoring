#!/bin/bash

# Save output to a temporary file
monitoring_report="/tmp/monitoring_report.txt"
exec > "$monitoring_report" 2>&1

print_header() {
  echo -e "\n\e[1;32m$1\e[0m"
}

print_header "HOST Info"

# Check if connected to Internet or not
ping -c 1 google.com &> /dev/null && echo "Internet: Connected" || echo "Internet: Disconnected"
echo " "
# Check OS Type
os=$(uname -o)
echo "Operating System Type: $os"
echo " "

# Check OS Release Version and Name
os_version=$(cat /etc/os-release | grep PRETTY_NAME | cut -d "=" -f 2 | tr -d '"')
echo "OS Version: $os_version"
echo " "

# Check Architecture
architecture=$(uname -m)
echo "Architecture: $architecture"
echo " "

# Check Kernel Release
kernel_release=$(uname -r)
echo "Kernel Release: $kernel_release"
echo " "

# Check Hostname
hostname=$(hostname)
echo "Hostname: $hostname"
echo " "

# Check Internal IP
internal_ip=$(hostname -I)
echo "Internal IP: $internal_ip"
echo " "

# Check External IP
external_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "External IP: $external_ip"
echo " "

# Check DNS Servers
dns_servers=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
echo "DNS Servers: $dns_servers"
echo " "

# Check Logged In Users
logged_in_users=$(who)
echo "Logged In Users: $logged_in_users"
echo " "

# Check RAM Usage
ram_usage=$(free -h | grep Mem | awk '{print $3 "/" $2}')
echo "RAM Usage: $ram_usage"
echo " "

# Check Swap Usage
swap_usage=$(free -h | grep Swap | awk '{print $3 "/" $2}')
echo "Swap Usage: $swap_usage"
echo " "

# Check Disk Usage
disk_usage=$(df -h | grep "/dev/xvda"  | awk '{print $1 "= " $5}')
echo "Disk Usage: $disk_usage"
echo " "

# Check Load Average
load_average=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
echo "Load Average: $load_average"
echo " "

# Check System Uptime
uptime=$(uptime -p)
echo "System Uptime: $uptime"
echo " "


# Function to print section headers
print_header() {
  echo -e "\n\e[1;32m$1\e[0m"
}

print_subheader() {
  echo -e "\n\e[1;33m$1\e[0m"
}

# Function to print information with indentation
print_info() {
  echo -e "  $1"
}

# Check the status of the Docker service
print_header "Checking Docker Service Status"
docker_status=$(systemctl is-active docker)
if [ "$docker_status" != "active" ]; then
  echo -e "\e[91mError:\e[0m Docker service is not running!"
  exit 1
else
  echo "Docker service is active."
fi

# List running containers
print_header "Running Containers"
running_containers=$(docker ps --format "{{.Names}}")
if [ -z "$running_containers" ]; then
  echo "No running containers found."
else
 #echo -e "\e[92mRunning containers:\e[0m"
  for container in $running_containers; do
    print_info "$container"
  done
fi

# List all containers
print_header "All Containers"
all_containers=$(docker ps -a --format "{{.Names}}")
if [ -z "$all_containers" ]; then
  echo "No containers found."
else
 #echo -e "\e[94mAll containers:\e[0m"
  for container in $all_containers; do
    print_info "$container"
  done
fi

# Collect additional information about containers
print_header "Additional Information about Containers"
for container_name in $all_containers; do
  print_subheader "Container: $container_name"

 
  # Get resource usage
  resource_info=$(docker stats --no-stream --format "table Container Name: {{.Container}}\tCPU Usage: {{.CPUPerc}}\tMemory Usage:{{.MemUsage}}\tNetwork I/O:{{.NetIO}}\tBlockI/O:{{.BlockIO}}" "$container_name" | tail -n 1)
  print_info "Resource Usage:"
  print_info "$resource_info"

done

########################################################################

function send_notification {
    local recipient="huseyinnas2001@hotmail.com"
    local msmtp_config="/home/huseyin/.msmtprc"

    echo -e "Subject: System Resource Notification\n\n$1" | msmtp -a fixcloud $recipient
}

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

# RAM Status Check
ram_usage=$(free | awk '/Mem/{printf "%.2f", $3/$2*100}')
if [ "$(echo "$ram_usage > 80" | bc -l)" -eq 1 ]; then
    send_notification "RAM usage is high: $ram_usage%"
fi


# Remove ANSI color codes
sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$monitoring_report" > "$monitoring_report.txt"


# Sending the printout as mail
send_notification "Monitoring Report\n$(cat /tmp/monitoring_report.txt.txt)"

