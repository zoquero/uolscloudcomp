#!/bin/bash

#
# Ejecución de sbench.
# @see https://github.com/zoquero/sbench
# angel.galindo@uols.org
# 20191208
#

cd sbench
./sbench -t mem -p 100,104857600
./sbench -t cpu -p 10000000,1
./sbench -t cpu -p 10000000,2
./sbench -t cpu -p 10000000,4
./sbench -t cpu -p 10000000,8
./sbench -t disk_w -p 2560,4096,4,/tmp/_sbench.d
