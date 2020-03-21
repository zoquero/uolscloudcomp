#!/usr/bin/env python3
#
# Uso: python s08/boto3_s3_get_file.py bucket_name remote_object_name local_file_name
# Ej:  python s08/boto3_s3_get_file.py uols-test-s3 file.txt file.txt
#

import sys
import boto3
from io import StringIO
bucket_name = sys.argv[1]
object_name = sys.argv[2]
local_file_name = sys.argv[3]
s3_resource = boto3.resource('s3')
s3_object = s3_resource.Object(bucket_name=bucket_name, key=object_name)
s3_data = s3_object.get()['Body'].read()
f = open(local_file_name, "w")
f.write(s3_data)
f.close()
