#!/bin/bash

#
# Script para borrar todos los S3 bucket y todas las intancias EC2
#
# Precaucación! Realmente borra todos esos recursos.
# Debe usarse sólo sabiendo qué se está ejecutando.
#
# angel.galindo@uols.org 20191228
#

if [ "$1" != "-f" ]; then
  echo -n "¿Estás realmente seguro? (y|N) "
  read c
  if [ "$c" != "y" ]; then
    exit 1
  fi
fi

echo "Borrando todos los buckets: " 
for bucket in $(aws2 s3 ls | awk '{print $3}'); do
  aws2 s3 rb s3://$bucket --force
  if [ $? -ne 0 ]; then
    echo "Errores borrando el bucket $bucket"
  fi
done
echo

echo "Borrando todas las instancias: " 
for instance in $(aws2 ec2 describe-instances | jq -r '.Reservations[].Instances[].InstanceId'); do
  aws2 ec2 terminate-instances --instance-ids "$instance"
  if [ $? -ne 0 ]; then
    echo "Errores borrando la instancia $instance"
  fi
done
