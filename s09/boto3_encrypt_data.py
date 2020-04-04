#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :
#
# Script para cifrar con una clave simétrica de datos usando KMS
#
# Uso: python s09/boto3_encrypt_data.py local_file_name (-v)
#
import aws_encryption_sdk
import time
import sys

key='arn:aws:kms:us-east-1:70702xxxxxxx:key/23ebxxxx-xxxx-xxxx-xxxx-2f54xxxxxxxx'

file_name = sys.argv[1]
if len(sys.argv) > 2 and sys.argv[2] == '-v':
  verbose_mode = 1
else:
  verbose_mode = 0

# Leemos el fichero
file_handler = open(file_name, "r")
plain_text_data = file_handler.read()
file_handler.close()

# ciframos
kms_key_provider = aws_encryption_sdk.KMSMasterKeyProvider(key_ids=[ key ])
start = time.time()
encrypted_data, encryptor_header = aws_encryption_sdk.encrypt(
    source=plain_text_data,
    key_provider=kms_key_provider
)
end = time.time()
elapsed_time=end-start

# Mostramos resultados
if(verbose_mode):
  print('plain_text_data=' + plain_text_data)
  print('encrypted_data=' + encrypted_data)
print('elapsed_time=' + str(elapsed_time))
