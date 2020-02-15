#!/bin/bash

#
# Instalación del AWS CLI en Ubuntu soportado por AWS
#
# Instalación de la AWS CLI versión 2 en Linux o Unix
# https://docs.aws.amazon.com/es_es/cli/latest/userguide/install-cliv2-linux.html
#
# Probado en Ubuntu 18.04 LTS con AWS CLI 2
# angel.galindo@uols.org
# 20191208
#

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install unzip
curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

