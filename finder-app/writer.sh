#!/bin/bash

# Acepta los siguientes argumentos: el primer argumento es una ruta
# completa a un archivo (incluyendo el nombre del archivo) en el sistema
# de archivos, referido más abajo como writefile; el segundo argumento
# es una cadena de texto que se escribirá dentro de este archivo, referido
# más abajo como writestr
# Sale con el valor 1 de error e imprime las sentencias si no se especificó
# alguno de los argumentos anteriores

if [ $# -ne 2 ]
then
  echo "Calling this script it must input two parameters."
  exit 1
fi

if [ -e $1 ]
then
  sudo rm $1
else
  sudo mkdir -p $1  || {
    echo "Wrong path to file."
    exit 1
  }
  sudo rm -r $1
fi

# Crea un nuevo fichero con nombre y ruta writefile con contenido writestr,
# sobrescribiendo cualquier fichero existente y creando la ruta si no existe.
# Sale con el valor 1 y una sentencia de error si no se ha podido crear el fichero.

sudo echo $2 > $1 || {
  echo "Error writting on $1 file."
  exit 1
}
