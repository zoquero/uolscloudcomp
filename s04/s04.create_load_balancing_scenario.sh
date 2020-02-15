#!/bin/bash

#
# Script para aprovisionar y luego limpiar
# el entorno del entregable de la cuarta sesión.
#
# Tarda de 11 a 12 minutos en aprovisionar y liberar
#
# Es sólo una prueba de concepto.
# Si quieres desplegar infraestructura a nivel masivo en entornos productivos
# échale una ojeada a Terraform https://www.terraform.io/ o al propio
# AWS CloudFormation o a alguna otra solución de "Infraestructure as code".
#
# Probado en Ubuntu 18.04 LTS con AWS CLI 2
#
# angel.galindo@uols.org
# 20191212
#

#-----------
# Funciones:
#-----------

function preconditions() {
  if [ ! -f "${key_name}.pem" ]; then
    echo "Crea el fichero ${key_name}.pem así: 'nano ${key_name}.pem', pega sobre él el contenido de tu fichero de claves y para salir pulsa 'Control X'"
    exit 1
  fi

  aws2 ec2 describe-instances > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "\nERROR: AWS CLI no parece estar dando respuesta."
    echo "       Revisa tu fichero .aws/credentials y tu conectividad."
    exit 1
  fi

  if [ "$elb_type" = "application" ]; then
    if [ "$elb_protocol" != "HTTP" -a "$elb_protocol" != "HTTPS" ]; then
      echo "ERROR: Un ELB de tipo 'application' sólo puede usar los protocolos 'HTTP' o 'HTTPS'"
      exit 1
    fi
  elif [ "$elb_type" = "network" ]; then
    if [ "$elb_protocol" != "TCP" ]; then
      echo "ERROR: Un ELB de tipo 'network' sólo puede usar el protocolo 'TCP'"
      exit 1
    fi
  else
    echo "ERROR: Un ELB no-clásico sólo puede ser de tipo 'application' o 'network'"
    exit 1
  fi

}

function create_subnets() {
  # Crear la subnet de la primera AZ:
  az1_subnet_create_output=$(aws2 ec2 create-subnet --vpc-id $vpc_id --cidr-block $az1_subnet_cidr --availability-zone $az1)
  az1_subnet_id=$(echo $az1_subnet_create_output | jq -r '.Subnet.SubnetId')
  if [ -z "$az1_subnet_id" ]; then echo "Error creando subnet $az1_subnet_cidr"; exit 1; fi
  az1_subnet_describe_output=$(aws2 ec2 describe-subnets --subnet-ids $az1_subnet_id --query 'Subnets[*].{Available:State}')
  az1_subnet_is_available=$(echo $az1_subnet_describe_output | jq -r '.[].Available')
  echo "Subnet creada en el VPC $vpc_id para la AZ $az1, CIDR=$az1_subnet_cidr, SubnetId=$az1_subnet_id, Available=$az1_subnet_is_available"
  
  # Crear la subnet de la segunda AZ:
  az2_subnet_create_output=$(aws2 ec2 create-subnet --vpc-id $vpc_id --cidr-block $az2_subnet_cidr --availability-zone $az2)
  az2_subnet_id=$(echo $az2_subnet_create_output | jq -r '.Subnet.SubnetId')
  if [ -z "$az2_subnet_id" ]; then echo "Error creando subnet $az2_subnet_cidr"; exit 1; fi
  az2_subnet_describe_output=$(aws2 ec2 describe-subnets --subnet-ids $az2_subnet_id --query 'Subnets[*].{Available:State}')
  az2_subnet_is_available=$(echo $az2_subnet_describe_output | jq -r '.[].Available')
  echo "Subnet creada en el VPC $vpc_id para la AZ $az2, CIDR=$az2_subnet_cidr, SubnetId=$az2_subnet_id, Available=$az2_subnet_is_available"

  if [ "$az1_subnet_is_available" != 'available' -o "$az1_subnet_is_available" != 'available' ]; then
    echo "ERROR: Alguna de las subnets no están disponibles, probablemente ya exista alguna subnet con el direccionamiento $az1_subnet_cidr o $az2_subnet_cidr"
    exit 1
  fi
}

function create_security_group() {
  # Crear el Security Group de servidor web:
  security_group_create_output=$(aws2 ec2 create-security-group --group-name $sg_name --description "SG WebServer: HTTP y SSH" --vpc-id $vpc_id)
  security_group_id=$(echo $security_group_create_output | jq -r '.GroupId')
  if [ -z "$security_group_id" ]; then echo "ERROR: No se ha podido crear el Security Group $sg_name, quizás ya exista"; exit 1; fi

  # Añadir al Security Group las reglas que dan acceso a los puertos 22 y 80 TCP:
  aws2 ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 80 --cidr 0.0.0.0/0
  aws2 ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr 0.0.0.0/0

# # Ver el Security Group:
# sg_creado_describe_output=$(aws2 ec2 describe-security-groups --group-ids $security_group_id --query 'SecurityGroups[*].{GroupName:GroupName,GroupId:GroupId}')
# sg_creado_GroupName=$(echo $sg_creado_describe_output | jq -r '.[].GroupName')
# sg_creado_GroupId=$(  echo $sg_creado_describe_output | jq -r '.[].GroupId')
# echo "Security group creado: $sg_creado_GroupName, id=$sg_creado_GroupId"

  echo "Security group creado: $sg_name, con id=$security_group_id"
}

function create_instances() {
  # Crear instancias:
  instance_1_create_output=$(aws2 ec2 run-instances --image-id $image_id --key-name $key_name --security-group-ids $security_group_id --instance-type $instance_type --placement AvailabilityZone=$az1 --subnet-id=$az1_subnet_id --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=inst1_az1}]')
  instance_1_id=$(echo $instance_1_create_output | jq -r '.Instances[].InstanceId')
  
  instance_2_create_output=$(aws2 ec2 run-instances --image-id $image_id --key-name $key_name --security-group-ids $security_group_id --instance-type $instance_type --placement AvailabilityZone=$az2 --subnet-id=$az2_subnet_id --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=inst1_az2}]')
  instance_2_id=$(echo $instance_2_create_output | jq -r '.Instances[].InstanceId')
  
  # Deberíamos esperar en un bucle hasta que estuvieran creadas y con
  # IPs asignadas, pero por ahora lo apañaremos esperando un par de segundos
  sleep 2
  
  instance_1_describe_output=$(aws2 ec2 describe-instances --instance-ids $instance_1_id)
  instance_1_public_ip=$(echo $instance_1_describe_output | jq -r '.Reservations[].Instances[].PublicIpAddress')
  
  instance_2_describe_output=$(aws2 ec2 describe-instances --instance-ids $instance_2_id)
  instance_2_public_ip=$( echo $instance_2_describe_output | jq -r '.Reservations[].Instances[].PublicIpAddress')
  instance_2_private_ip=$(echo $instance_2_describe_output | jq -r '.Reservations[].Instances[].PrivateIpAddress')
  
  echo "Instancias creadas: 1=$instance_1_id ($az1) y 2=$instance_2_id ($az2)"
  echo "Refresca la consola de AWS y mira desde allí las instancias."
  echo
  echo "En breve podrás conectarte a la instancia #1 ($instance_1_id) así:"
  echo "ssh -i ${key_name}.pem ubuntu@$instance_1_public_ip"
  echo "                         y a la instancia #2 ($instance_2_id) así:"
  echo "ssh -i ${key_name}.pem ubuntu@$instance_2_public_ip"
  echo
}

function init_instances() {
  cat << END_OF_HERE_DOCUMENT > /tmp/init.sh

sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install apache2 --fix-missing -y
sudo a2enmod cgi
sudo systemctl restart apache2

# Documento estático:
EC2_INSTANCE_ID="\$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)"
EC2_AVAIL_ZONE="\$(wget  -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone)"
EC2_REGION="\$(echo "\$EC2_AVAIL_ZONE" | sed 's/[a-z]\$//')"
echo "<html><body>Instancia con ID <strong>\$EC2_INSTANCE_ID</strong> y ubicada en AZ <strong>\$EC2_AVAIL_ZONE</strong> de region <strong>\$EC2_REGION</strong></body></html>" > /tmp/index.html
sudo mv /tmp/index.html /var/www/html/index.html

# Documento dinámico:
echo "#!/bin/bash"                       > /usr/lib/cgi-bin/whoami.sh
echo "echo \"Content-type: text/html\"" >> /usr/lib/cgi-bin/whoami.sh
echo "echo "                            >> /usr/lib/cgi-bin/whoami.sh
echo "EC2_INSTANCE_ID=\"\$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)\""                 >> /usr/lib/cgi-bin/whoami.sh
echo "EC2_AVAIL_ZONE=\"\$(wget  -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone)\"" >> /usr/lib/cgi-bin/whoami.sh
echo "EC2_REGION=\"\$(echo \"\$EC2_AVAIL_ZONE\" | sed 's/[a-z]\$//')\""                                         >> /usr/lib/cgi-bin/whoami.sh
echo "echo \"<html><body>Instancia con ID <strong>\$EC2_INSTANCE_ID</strong> y ubicada en AZ <strong>\$EC2_AVAIL_ZONE</strong> de region <strong>\$EC2_REGION</strong></body></html>\"" >> /usr/lib/cgi-bin/whoami.sh
sudo chmod 0755 /usr/lib/cgi-bin/whoami.sh

END_OF_HERE_DOCUMENT

  echo "Esperaremos a que las instancias estén disponibles, puede ser medio minuto:"
  echo -n "$instance_1_id: "
  while true; do
    echo -n "."
    sleep 1
    nc -w 2 -zv $instance_1_public_ip 22 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo -e "\nLa instancia $instance_1_id ya está disponible"
      break
    fi
  done
  echo -n "$instance_2_id: "
  while true; do
    echo -n "."
    sleep 1
    nc -w 2 -zv $instance_2_public_ip 22 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo -e "\nLa instancia $instance_2_id ya está disponible"
      break
    fi
  done
  
  # Igualmente esperamos un poco a que las instancias acaben de arrancar
  sleep 10
  
  echo -e "\nPreparamos la instancia $instance_1_id, puede llevar 2 minutos\n(puedes mirar su progreso en /tmp/init_${instance_1_id}.out):" 
  r=0
  scp -q -o "StrictHostKeyChecking=no" -i ${key_name}.pem /tmp/init.sh ubuntu@$instance_1_public_ip:/tmp/
  r=$?
  ssh -q -o "StrictHostKeyChecking=no" -i ${key_name}.pem ubuntu@$instance_1_public_ip "sudo bash /tmp/init.sh" > /tmp/init_${instance_1_id}.out 2>&1
  let r+=$?
  if [ $r -ne 0 ]; then
    echo "ERRORES preparando la instancia $instance_1_id"
  else
    echo "Instancia $instance_1_id preparada." 
  fi

  echo -e "\nPreparamos la instancia $instance_2_id, puede llevar 2 minutos\n(puedes mirar su progreso en /tmp/init_${instance_2_id}.out):" 
  r=0
  scp -q -o "StrictHostKeyChecking=no" -i ${key_name}.pem /tmp/init.sh ubuntu@$instance_2_public_ip:/tmp/
  r=$?
  ssh -q -o "StrictHostKeyChecking=no" -i ${key_name}.pem ubuntu@$instance_2_public_ip "sudo bash /tmp/init.sh" > /tmp/init_${instance_2_id}.out 2>&1
  let r+=$?
  if [ $r -ne 0 ]; then
    echo "ERRORES preparando la instancia $instance_2_id"
  else
    echo "Instancia $instance_2_id preparada." 
  fi
  
}

function test_http_services_working() {
  echo
  echo "Si ya están bien preparadas podrás probarlo abriendo estas URLs con un navegador:"
  echo "* http://$instance_1_public_ip/"
  echo "* http://$instance_2_public_ip/"
  
  curl -q "http://$instance_1_public_ip/" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR: La instancia $instance_1_id no parece estar respondiendo, quizás no ha podido contactar con sus repositorios de paquetes. Puedes mirar su log de ejecución disponible en /tmp/init_${instance_1_id}.out de este equipo y puedes intentar volver a ejecutar a mano su script ubuntu@$instance_1_public_ip:/tmp/init.sh o bien deja que este script finalice liberando todos los recuersos y vuelve a probar".
    read -p "Pulsa [Enter] para seguir"
  fi
  
  curl -q "http://$instance_2_public_ip/" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR: La instancia $instance_2_id no parece estar respondiendo, quizás no ha podido contactar con sus repositorios de paquetes. Puedes mirar su log de ejecución disponible en /tmp/init_${instance_2_id}.out de este equipo y puedes intentar volver a ejecutar a mano su script ubuntu@$instance_2_public_ip:/tmp/init.sh o bien deja que este script finalice liberando todos los recuersos y vuelve a probar".
    read -p "Pulsa [Enter] para seguir"
  fi
  
  echo "Comprobado, están listas."
}

function create_elb() {
  echo -e "\nAhora vamos a crear el ELB y el Target Group:"
  if [ "$elb_type" = "application" ]; then
    create_elb_output=$(aws2 elbv2 create-load-balancer --name $elb_name --type $elb_type --security-groups $security_group_id --subnets $az1_subnet_id $az2_subnet_id)
  else
    create_elb_output=$(aws2 elbv2 create-load-balancer --name $elb_name --type $elb_type                                      --subnets $az1_subnet_id $az2_subnet_id)
  fi
  elb_arn=$(echo $create_elb_output | jq -r '.LoadBalancers[].LoadBalancerArn')
  echo "Creado ELB $elb_name con ARN $elb_arn"
  echo "Esperaremos hasta que esté disponible, puede tardar un par de minutos:"
  
  elb_state=""
  while [ "$elb_state" != "active" ]; do
    echo -n "."
    sleep 1
    elb_state=$(get_elb_state $elb_name)
  done
  echo -e "\nEl elb $elb_name ya está activo"
  
  desc_load_bal_output=$(aws2 elbv2 describe-load-balancers --names $elb_name)
  elb_dns_name=$(echo $desc_load_bal_output | jq -r '.LoadBalancers[].DNSName')
}

function create_target_group() {
  create_tg_output=$(aws2 elbv2 create-target-group --name $elb_target_group --protocol $elb_protocol --port 80 --vpc-id $vpc_id)
  tg_arn=$(echo $create_tg_output | jq -r '.TargetGroups[].TargetGroupArn')
  echo "Creado Target Group con ARN $tg_arn"
  register_target_output=$(aws2 elbv2 register-targets --target-group-arn $tg_arn --targets Id=$instance_1_id Id=$instance_2_id)
  echo "Instancias $instance_1_id y $instance_2_id registradas en el Target Group"
  create_listener_output=$(aws2 elbv2 create-listener --load-balancer-arn $elb_arn --protocol $elb_protocol --port 80 --default-actions Type=forward,TargetGroupArn=$tg_arn)
  listener_arn=$(echo $create_listener_output | jq -r '.Listeners[].ListenerArn')
  echo "Listener creado con ARN $listener_arn"
}

function wait_for_target_group_members_working() {
  echo "Esperaremos a que todos los Grupos de Destino se muestren saludables, puede tardar 4 ó 5 minutos:"
  h="x"
  while [ "$h" != "" ]; do
    h=""
    for i in $(aws2 elbv2 describe-target-health --target-group-arn $tg_arn | jq -r '.TargetHealthDescriptions[].TargetHealth.State'); do
      echo -n "."
      sleep 1
      if [ "$i" != "healthy" ]; then
        h="${h}$i";
      fi
    done
  done
  echo -e "\nTodos los miembros del Grupo de Destino ya son saludables"
  echo "Abre la URL del ELB con un navegador: http://$elb_dns_name/cgi-bin/whoami.sh"
  echo
  echo "También puedes probarlo de continuo ejecutando este comando en otra ventana de terminal:"
  echo "while true; do curl -s -m 2 http://$elb_dns_name/cgi-bin/whoami.sh | cut -c 91-100 ; sleep 1; done"
  echo
  echo "Haz algunas pruebas: reinicia una instancia y mira cuánto tarda en reincorporarse al grupo."
  echo
  read -p "Cuando acabes las pruebas pulsa [Enter] para borrar los recursos creados."
  echo
}

function clean_up() {

  echo "Borramos el listener $listener_arn"
  aws2 elbv2 delete-listener --listener-arn $listener_arn
  echo "Borramos el ELB $elb_name"
  aws2 elbv2 delete-load-balancer --load-balancer-arn $elb_arn
  echo "Borramos el Target Group $tg_arn"
  aws2 elbv2 delete-target-group --target-group-arn $tg_arn
  echo "Borramos las instancias $instance_1_id y $instance_2_id"
  instance_1_terminate_output=$(aws2 ec2 terminate-instances --instance-ids $instance_1_id)
  instance_1_terminate_output_curr_state=$(echo $instance_1_terminate_output | jq -r '.TerminatingInstances[].CurrentState.Name')
  
  instance_2_terminate_output=$(aws2 ec2 terminate-instances --instance-ids $instance_2_id)
  instance_2_terminate_output_curr_state=$(echo $instance_2_terminate_output | jq -r '.TerminatingInstances[].CurrentState.Name')
  echo "Estado de finalización de la instancia $instance_1_id = $instance_1_terminate_output_curr_state"
  echo "Estado de finalización de la instancia $instance_2_id = $instance_2_terminate_output_curr_state"
  
  
  echo -n "Esperando la finalizaciòn de las instancias: "
  t1=""
  t2=""
  while [ "$t1" != "terminated" -a "$t2" != "terminated" ]; do
    echo -n "."
    sleep 1
    t1=$(get_terminating_instance_state $instance_1_id)
    t2=$(get_terminating_instance_state $instance_2_id)
  done
  echo -e "\nInstancias finalizadas"
  
  echo -n "Para borrar el Security Group y las subnets esperaremos a que ya no estén en uso: "
  used_network_interfaces="x"
  while [ "$used_network_interfaces" != "" ]; do
    echo -n "."
    sleep 1
    used_nics=$(aws2 ec2 describe-network-interfaces --filters "Name=subnet-id,Values=[$az1_subnet_id,$az2_subnet_id]")
  
    if [ -z "$used_nics" ]; then continue; fi
    used_network_interfaces=$(echo $used_nics | jq -r '.NetworkInterfaces[].Attachment.InstanceId')
  
  # echo "status="
  # aws2 ec2 describe-network-interfaces --filters Name=group-id,Values=[$security_group_id] | jq -r '.NetworkInterfaces[].Status'
  done
  echo -e "\nYa no están en uso"
  
  echo "Borramos el Security Group $security_group_id y las subnets $az1_subnet_id y $az2_subnet_id"
  r=0
  aws2 ec2 delete-security-group --group-id $security_group_id
  let r+=$?
  aws2 ec2 delete-subnet --subnet-id $az1_subnet_id
  let r+=$?
  aws2 ec2 delete-subnet --subnet-id $az2_subnet_id
  let r+=$?
  if [ $r -eq 0 ]; then
    echo "El script finaliza lliberando satisfactoriamente los recursos"
  else
    echo "No se ha podido liberar alguno de los recursos, deberás liberarlos a mano"
  fi
}

# arg: instance_id
function get_terminating_instance_state() {
  local instance_terminate_output
  local instance_terminate_output_curr_state
  instance_terminate_output=$(aws2 ec2 terminate-instances --instance-ids $1)
  instance_terminate_output_curr_state=$(echo $instance_terminate_output | jq -r '.TerminatingInstances[].CurrentState.Name')
  echo "$instance_terminate_output_curr_state"
}

# arg: elb_name
function get_elb_state() {
  local elb_output
  local elb_output_state
  elb_output=$(aws2 elbv2 describe-load-balancers --names $1)
  elb_output_state=$(echo $elb_output | jq -r '.LoadBalancers[].State.Code')
  echo "$elb_output_state"
}


#-------------------
# Cuerpo del script:
#-------------------

#
# Configuración:
#
az1=us-east-1a
az2=us-east-1b
vpc_id=vpc-ff206885 
image_id=ami-04b9e92b5572fa0d1
key_name=UolsTestKeys
az1_subnet_cidr=172.31.100.0/24
az2_subnet_cidr=172.31.200.0/24
sg_name=uols-webserver 
instance_type=t2.micro
elb_name=uols-elb
elb_target_group=uols-target-group
elb_type=application # ( network | application )
elb_protocol=HTTP # ( HTTP (para ALB) | HTTPS (para ALB) | TCP (para NLB) )

#
# Ejecución:
#
echo "Creación de un escenario de ELB sobre instancias en 2 AZs:"
preconditions
create_subnets
create_security_group
create_instances
init_instances
test_http_services_working
create_elb
create_target_group
wait_for_target_group_members_working
clean_up
