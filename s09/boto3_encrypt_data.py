#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :
#
# Script para cifrar un fichero usando KMS
#
# Uso: python s09/boto3_encrypt_data.py plaintext_file_name encrypted_file_name (-v)
#
import aws_encryption_sdk
import time
import sys

key='arn:aws:kms:us-east-1:70702xxxxxxx:key/23ebxxxx-xxxx-xxxx-xxxx-2f54xxxxxxxx'

plaintext_file_name = sys.argv[1]
encrypted_file_name = sys.argv[2]
if len(sys.argv) > 3 and sys.argv[3] == '-v':
  verbose_mode = 1
else:
  verbose_mode = 0

# Leemos el fichero
file_handler = open(plaintext_file_name, "r")
plaintext_data = file_handler.read()
file_handler.close()

# ciframos
kms_key_provider = aws_encryption_sdk.KMSMasterKeyProvider(key_ids=[ key ])
start = time.time()
encrypted_data, encryptor_header = aws_encryption_sdk.encrypt(
    source=plaintext_data,
    key_provider=kms_key_provider
)
end = time.time()
elapsed_time=end-start

# generamos fichero cifrado
f = open(encrypted_file_name, "w")
f.write(encrypted_data)
f.close()

# Mostramos resultados
if(verbose_mode):
  print('plaintext_file_name=' + plaintext_file_name)
  print('plaintext_data=' + plaintext_data)
  print('encrypted_data=' + encrypted_data)
  print('encrypted_file_name=' + encrypted_file_name)
print('elapsed_time=' + str(elapsed_time))
