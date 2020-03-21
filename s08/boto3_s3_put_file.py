#!/usr/bin/env python3
#
# Uso: python s08/boto3_s3_put_file.py local_file_name bucket_name remote_object_name
# Ej:  python s08/boto3_s3_put_file.py file.txt uols-test-s3 file.txt
#
import sys
import boto3
local_file_path = sys.argv[1]
bucket_name = sys.argv[2]
object_name = sys.argv[3]
s3 = boto3.client('s3')
s3.upload_file(local_file_path, bucket_name, object_name)
