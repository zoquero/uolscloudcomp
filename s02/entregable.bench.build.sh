#!/bin/bash

#
# Construcción de sbench
# Probado en Ubuntu 18.04 LTS
# angel.galindo@uols.org
# 20191208
#

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install gcc git make libcurl4 libcurl4-openssl-dev -y
git clone https://github.com/zoquero/sbench.git
cd sbench/
make
