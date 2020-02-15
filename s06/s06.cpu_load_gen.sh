#!/bin/bash

#
# Genera contínuamente dos intérvalos distintos de carga de CPU
#
# angel.galindo@uols.org
# 20191231
#

a=0
while true; do
  if [ $a -eq 0 ]; then
    echo "un"
    a=1
    for i in $(seq 1 260); do
      dd bs=512 count=1024000 if=/dev/zero of=/dev/null >/dev/null 2>&1 
      echo -n "."
      sleep 1
    done 
  else
    echo "dos"
    a=0
    for i in $(seq 1 460); do
      dd bs=512 count=1024000 if=/dev/zero of=/dev/null >/dev/null 2>&1 
      echo -n "."
    done
  fi
  echo
  sleep 1
done 
