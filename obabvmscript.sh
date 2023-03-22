#!/bin/bash

echo "Name of resource groupe?"
read a
echo "Location of resource groupe?"
read b
az group create --name $a --location $b

echo "resource groupe name?"
read c
echo "name?"
read d
echo "image name?"
read i
echo "admin-username?"
read f
az vm create \
    --resource-group $c \
    --name $d \
    --image $i \
    --admin-username $f \
    --generate-ssh-keys
