#!/bin/bash

# This script is used for setting an static IPv4 address

#INTERFACE='/etc/systemd/network/lan0.network'
INTERFACE='./lan0.network'

usage() {
  echo "Usage: ${0} [-d] IP_ADDRESS"
  echo 'Manage network by setting static IPv4'
  echo -e "-d\tSet back to default setting (all arguments after -d will be omitted)"
  exit 1
}

set_default_settings() {
  echo 'Reverting to default settings'
  echo -e "[Match]\nName=eth0\n\n[Network]\nDHCP=ipv4" > "${INTERFACE}"
}

validate_ip() {
  # range:
  # 10.0.0.0 to 10.255.255.255
  # 172.16.0.0 to 172.31.255.255
  # 192.168.0.0 to 192.168.255.255
  local IP_REGEX='10.0.0.0'

  if [[ ! "${IP_ADDRESS}" =~ "${IP_REGEX}" ]]
  then
    echo "Invalid IP: ${IP_ADDRESS}"
    exit 1
  fi
}

set_static_ip() {
  local GATEWAY=''
  local DNS=''

  echo "Setting static IP: ${IP_ADDRESS}"
  echo -e "[Match]\nName=enp8s0\n\n[Network]\nAddress=${IP_ADDRESS}\nGateway=${GATEWAY}\nDNS=${DNS}" > ${INTERFACE}
}

# Check if script was run with sudo/root privileges
if [[ "${UID}" -ne 0  ]]
then
  echo 'Please run with sudo or as a root' >&2
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
    echo 'Warning: all arguments after -d will be omitted'
  fi
  
  set_default_settings "${INTERFACE}"
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

  # First argument is treated as IP_ADDRESS
  IP_ADDRESS="${1}"
  validate_ip "${IP_ADDRESS}"

  # Check if IP_ADDRESS validation succeeded
  if [[ "${?}" -eq 0 ]]
  then
    set_static_ip "${IP_ADDRESS}" "${INTERFACE}"
  fi
fi
