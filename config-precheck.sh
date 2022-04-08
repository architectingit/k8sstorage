#!/bin/bash

# Define some colours for later
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33]'
NC='\033[0m' # No Color

apt -y update

echo -e "${GREEN}Checking installed software and features....${NC}"

dpkg-query --show docker.io &> /dev/null

if [ $? -ne 0 ]
  then
     apt-get -y install docker.io
     systemctl enable docker
     echo -e "${ORANGE}Installed and started Docker${NC}"
  else 
     echo -e "${GREEN}Docker already installed${NC}"
fi
dpkg-query --show jq &> /dev/null
if [ $? -ne 0 ]
  then
     apt -y install jq
     echo -e "${ORANGE}Installed jq${NC}"
  else
     echo -e "${GREEN}jq already installed${NC}"
fi

echo -e "${GREEN}Configuring StorageOS pre-flight kernel module installations"
mkdir -p /var/lib/storageos
echo -e "${GREEN}No specific pre-requisites for Portworx are required${NC}"
echo -e "${GREEN}Pre-testing checks and installations completed${NC}"

