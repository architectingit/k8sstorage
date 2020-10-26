#!/bin/bash

apt -y update

echo "checking installed software and features"

dpkg-query --show docker.io &> /dev/null

if [ $? -ne 0 ]
  then
     apt-get -y install docker.io
     systemctl enable docker
     echo "Installed and started Docker"
  else 
     echo "Docker already installed"
fi
dpkg-query --show jq &> /dev/null
if [ $? -ne 0 ]
  then
     apt -y install jq
     echo "Installed jq"
  else
     echo "jq already installed"
fi
