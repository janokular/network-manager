#!/bin/bash

# This script is used for setting an static IPv4 address
# It was designed for minimal instalation of Debian 12

usage() {
  echo "Usage: ${0} [-d] IP_ADDRESS"
  echo 'Manage network by setting static or dynamic IPv4'
  echo -e "-d\tSet back to default setting (all arguments after -d will be omitted)"
  exit 1
}

set_default_settings() {
  echo 'Reverting to default settings...'
}

validate_ip() {
  local IP_REGEX="255.255.255.255"
  
  if [[ ! "${IP_ADDRESS}" =~ "${IP_REGEX}" ]]
  then
    echo "Invalid IP: ${IP_ADDRESS}"
    exit 1
  fi
}

set_static_ip() {
  echo "Setting static IP to: ${IP_ADDRESS}"
}

# Check if script was run with sudo/root priviges
if [[ "${UID}" -ne 0  ]]
then
  echo "Please run with sudo or as a root" >&2
  exit 1
fi

# Check options provided by the user
while getopts d OPTION &> /dev/null
do
  case ${OPTION} in
    d) DEFAULT='true' ;;
    ?) usage ;;
  esac
done

# Remove options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

if [[ "${DEFAULT}" = 'true' ]]
then
  # Display warning massage when user provide arguments after option -d
  if [[ "${#}" -gt 0 ]]
  then
    echo 'Warrning: all arguments after -d will be omitted'
  fi
  
  set_default_settings
else
  # Check if user provided only one argument for IP_ADDRESS
  if [[ "${#}" -lt 1 ]]
  then
    echo 'No IP_ADDRESS'
    usage
  elif [[ "${#}" -gt 1 ]]
  then
    echo 'Too many arguments'
    usage
  fi

  # First argument is treated as an IP_ADDRESS
  IP_ADDRESS="${1}"
  validate_ip "${IP_ADDRESS}"

  # Check if IP_ADDRESS validation succeeded
  if [[ "${?}" -eq 0 ]]
  then
    set_static_ip "${IP_ADDRESS}"
  fi
fi
