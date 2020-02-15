#!/bin/bash

#
# Script para aprovisionar y luego limpiar
# el entorno del entregable de la tercera sesión.
#
# Nota: Es sólo un borrador no-robusto para laboratorio, pues no verifica
# el resultado de las acciones ni vigila la eliminación
# de las dependencias antes de eliminar recursos.
#
# Probado en Ubuntu 18.04 LTS con AWS CLI 2
#
# angel.galindo@uols.org
# 20191211
#

az=us-east-1a
vpc=vpc-ff206885 
image_id=ami-04b9e92b5572fa0d1
key_name=UolsTestKeys
client_subnet_cidr=172.31.100.0/24
server_subnet_cidr=172.31.200.0/24
sg_name=uols-webserver 
instance_type=t2.micro

# Crear la subnet para el cliente:
client_subnet_id=$(aws2 ec2 create-subnet --vpc-id $vpc --cidr-block $client_subnet_cidr --availability-zone $az | jq -r '.Subnet.SubnetId')
client_subnet_available=$(aws2 ec2 describe-subnets --subnet-ids $client_subnet_id --query 'Subnets[*].{Available:State}' | jq -r '.[].Available')
echo "Subnet para el cliente,  CIDR=$client_subnet_cidr, SubnetId=$client_subnet_id, Available?=$client_subnet_available"
# Crear la subnet para el servidor:
server_subnet_id=$(aws2 ec2 create-subnet --vpc-id $vpc --cidr-block $server_subnet_cidr --availability-zone $az | jq -r '.Subnet.SubnetId')
server_subnet_available=$(aws2 ec2 describe-subnets --subnet-ids $server_subnet_id --query 'Subnets[*].{Available:State}' | jq -r '.[].Available')
echo "Subnet para el servidor, CIDR=$server_subnet_cidr, SubnetId=$server_subnet_id, Available?=$server_subnet_available"

# Ver subnets creadas:
# aws2 ec2 describe-subnets --subnet-ids $client_subnet_id --query 'Subnets[*].{Subnet_Id:SubnetId,CIDR:CidrBlock}'
# aws2 ec2 describe-subnets --subnet-ids $server_subnet_id --query 'Subnets[*].{Subnet_Id:SubnetId,CIDR:CidrBlock}'

# Crear el Security Group de servidor web:
security_group_id=$(aws2 ec2 create-security-group --group-name $sg_name --description "SG para mi servidor web" --vpc-id $vpc | jq -r '.GroupId')
# Añadir a Security Group regla que da acceso al puerto 80 TCP:
aws2 ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 80 --cidr 0.0.0.0/0
aws2 ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr 0.0.0.0/0
# Ver el Security Group:
# aws2 ec2 describe-security-groups --group-ids $security_group_id --query 'SecurityGroups[*].{GroupName:GroupName,GroupId:GroupId}' 
sg_creado_GroupName=$(aws2 ec2 describe-security-groups --group-ids $security_group_id --query 'SecurityGroups[*].{GroupName:GroupName}' | jq -r '.[].GroupName')
sg_creado_GroupId=$(  aws2 ec2 describe-security-groups --group-ids $security_group_id --query 'SecurityGroups[*].{GroupId:GroupId}'     | jq -r '.[].GroupId')
echo "Security group creado: $sg_creado_GroupName, id=$sg_creado_GroupId"

# Crear dos instancia cliente:
instance_client_id=$(aws2 ec2 run-instances --image-id $image_id --key-name $key_name --security-group-ids $security_group_id --instance-type $instance_type --placement AvailabilityZone=$az --subnet-id=$client_subnet_id --associate-public-ip-address | jq -r '.Instances[].InstanceId')
instance_server_id=$(aws2 ec2 run-instances --image-id $image_id --key-name $key_name --security-group-ids $security_group_id --instance-type $instance_type --placement AvailabilityZone=$az --subnet-id=$server_subnet_id --associate-public-ip-address | jq -r '.Instances[].InstanceId')

instance_client_public_ip=$( aws2 ec2 describe-instances --instance-ids $instance_client_id | jq -r '.Reservations[].Instances[].PublicIpAddress')
instance_server_public_ip=$( aws2 ec2 describe-instances --instance-ids $instance_server_id | jq -r '.Reservations[].Instances[].PublicIpAddress')
instance_server_private_ip=$(aws2 ec2 describe-instances --instance-ids $instance_server_id | jq -r '.Reservations[].Instances[].PrivateIpAddress')

echo "Instancias creadas: cliente=$instance_client_id y servidor=$instance_server_id"
echo "Refresca la consola de AWS y mira desde allí las instancias."
echo
echo "Puedes conectarte al cliente  ($instance_client_id) así:"
echo "ssh -i $key_name.pem ubuntu@$instance_client_public_ip"
echo
echo "Una vez dentro del cliente ejecuta estos comandos:"
echo "sudo apt-get update && sudo apt-get upgrade -y"
echo "sudo apt-get install apache2 -y"
echo "sudo sh -c 'echo \"Estàs en el cliente? Lo has conseguido!\" > /var/www/html/index.html'"
echo

echo "Puedes conectarte al servidor ($instance_server_id) así:"
echo "ssh -i $key_name.pem ubuntu@$instance_server_public_ip"
echo
echo "Una vez dentro del servidor ejecuta este comando:"
echo "curl http://$instance_server_private_ip"

echo
read -p "Cuando acabes pulsa [Enter] para borrar los recursos creados..."
echo

# Limpiar:
echo "Borramos los recursos."
aws2 ec2 terminate-instances --instance-ids $instance_client_id
aws2 ec2 terminate-instances --instance-ids $instance_server_id
echo "Espera un minuto, paciencia."
sleep 40 # Mejorable gestionando el resultado del comando anterior.
aws2 ec2 delete-security-group --group-id $security_group_id
aws2 ec2 delete-subnet --subnet-id $client_subnet_id
aws2 ec2 delete-subnet --subnet-id $server_subnet_id
