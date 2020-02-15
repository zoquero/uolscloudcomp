#!/bin/bash

#
# Consultar los metadatos de una instancia
# Probado en Ubuntu 18.04 LTS con AWS CLI 2
# angel.galindo@uols.org
# 20191210
#

EC2_INSTANCE_ID="$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)"
EC2_AVAIL_ZONE="$(wget  -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone)"
EC2_REGION="$(echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:')"
echo "Instancia con ID $EC2_INSTANCE_ID y ubicada en AZ $EC2_AVAIL_ZONE de region $EC2_REGION"
