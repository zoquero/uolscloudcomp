#!/bin/bash
#
# Se basa en el uso sbench.
# El script de construcción es src/s02/entregable.bench.build.sh
# @see https://github.com/zoquero/sbench
#
# angel.galindo@uols.org
# 20200101
#

# Ajusta la ruta
sbench="./sbench"

#
# Creamos un fichero útil para poder leerlo luego
# Lo creamos con contenido aleatorio para evitar sparse file y caché
# Tarda unos 11 minutos en una t2.micro
#
echo "Creamos el fichero que luego leeremos ($basura)"
basura="$HOME/basura.out"
head -c 5G </dev/urandom > "$basura"

#
# Generamos IO
#
echo "Comenzamos el bucle:"
while true; do
  # Primero generamos operaciones de escritura durante un cuarto de hora
  echo -n -e "\nEscritura: "
  for i in $(seq 1 44); do 
    "$sbench" -t disk_w -p 2560,4096,4,/tmp/_sbench.d > /dev/null
    # Cada una de estas llamadas a sbench dura aprox 30s en una t2.micro
    echo -n "."
  done

  # Luego generamos operaciones de lectura durante un cuarto de hora
  echo -n -e "\nLectura: "
  for i in $(seq 1 14); do
    "$sbench" -t disk_r_seq -p 1310720,4096,"$basura" > /dev/null
    # Cada una de estas llamadas a sbench dura aprox 1.5 minutos en una t2.micro
    echo -n "."
  done
done
