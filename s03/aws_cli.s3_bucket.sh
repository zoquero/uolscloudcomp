#!/bin/bash

#
# Algunos comandos S3
# Probado en Ubuntu 18.04 LTS con AWS CLI 2
# angel.galindo@uols.org
# 20191208
#

aws2 s3 mb s3://uols-test02
aws2 s3 cp /tmp/logo.png s3://uols-test/
aws2 s3 ls s3://uols-test/
aws2 s3 presign s3://uols-test/logo.png --expires-in 600
