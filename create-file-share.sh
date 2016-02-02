#!/bin/bash
# # Create Azure file share that will be used by front end VM's for moodledata directory
SharedStorageAccountName=$1
SharedAzureFileName=$2
SharedStorageAccountKey=$3

apt-get -y install nodejs-legacy
apt-get -y install npm
npm install -g azure-cli

sudo azure storage share create $SharedAzureFileName -a $SharedStorageAccountName -k $SharedStorageAccountKey
