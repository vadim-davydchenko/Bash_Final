#!/bin/bash

display_help() {
  echo "Usage: $0 [options] [sub-options]"
  echo
  echo "Options:"
  echo "-p, --proc          Work with /proc directory"
  echo "                      Usage example: -p cpuinfo --> cat /proc/cpuinfo"
  echo "-c, --cpu           Work with the processor"
  echo "-m, --memory        Work with memory"
  echo "                      Usage examples:"
  echo "                        -m, --memory --> free"
  echo "                        -m total, --memory total --> total - total available physical memory on the server"
  echo "                        -m available, --memory available --> available - memory available for use"
  echo "-d, --disks         Work with disks (use utility lsblk)"
  echo "-n, --network       Work with the network"
  echo "-la, --loadaverage  Display the average load on the system"
  echo "-k, --kill          Send signals to processes"
  echo "                      Usage example: -k 1234 SIGTERM --> kill -s SIGTERM 1234"
  echo "-o, --output        Save the results of the script to disk"
  echo "                      Usage example: -m -o output.txt"
  echo "-h, --help          Display this help message and exit"
}

proc_action() {
  if [ -z "$1" ]; then
    echo "Listing the /proc directory:"
    ls /proc
  else
    echo "Displaying the contents of the /proc/$1 file:"
    cat /proc/"$1"
  fi
}

memory_action() {
  case $1 in
    total)
      echo "Total available physical memory on the server:"
      free -h | awk '/^Mem:/ {print $2}'
      ;;
    available)
      echo "Memory available for use:"
      free -h | awk '/^Mem:/ {print $7}'
      ;;
    *)
      echo "Displaying the current state of memory:"
      free -h
      ;;
  esac
}

output_action() {
  output_file="$1"
  shift
  "$@" > "$output_file"
}

# Check for the existence of required utilities
command -v free >/dev/null 2>&1 || { echo "Error: 'free' utility not found. Please install it."; exit 1; }
command -v lsblk >/dev/null 2>&1 || { echo "Error: 'lsblk' utility not found. Please install it."; exit 1; }
command -v w >/dev/null 2>&1 || { echo "Error: 'w' utility not found. Please install it."; exit 1; }
command -v ifstat >/dev/null 2>&1 || { echo "Error: 'ifstat' utility not found. Please install ifstat package."; exit 1; }

# Process input arguments
if [ $# -eq 0 ]; then
  display_help
  exit 1
fi

arg="$1"
shift

case $arg in
  -p|--proc)
    proc_action "$@"
    ;;
  -c|--cpu)
    echo "Working with the processor:"
    cat /proc/loadavg
    ;;
  -m|--memory)
    memory_action "$@"
    ;;
  -d|--disks)
    echo "Working with disks:"
    lsblk
    ;;
  -n|--network)
    echo "Working with the network:"
    ifstat
    ;;
  -la|--loadaverage)
    echo "Displaying the average load on the system:"
    w
    ;;
  -k|--kill)
    pid="$1"
    signal="$2"
    echo "Sending signal $signal to process with PID $pid:"
    kill -s "$signal" "$pid"
    ;;
  -o|--output)
    output_action "$@"
    ;;
  -h|--help)
    display_help
    exit 0
    ;;
  *)
    echo "Unknown option: $arg"
    display_help
    exit 1
    ;;
esac