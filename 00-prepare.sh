#!/bin/bash
# Mise a jour et prerequis
apt-get update && apt-get upgrade -y
apt-get install -y curl wget gnupg apt-transport-https \
    ca-certificates software-properties-common

# Configurer l IP fixe si pas encore fait
# Editer /etc/netplan/00-installer-config.yaml
echo "IP de cette VM :"
ip a | grep "172.16" | awk '{print $2}'
