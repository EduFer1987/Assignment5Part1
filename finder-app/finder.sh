#!/bin/sh

# Acepta los siguientes argumentos de tiempo de ejecución: el primer argumento es una ruta a un
# directorio en el sistema de archivos, referido abajo como filesdir; el segundo argumento es una
# cadena de texto que será buscada dentro de estos archivos, referido abajo como searchstr
# Sale con el valor de retorno 1 error e imprime las sentencias si no se ha especificado alguno de los parámetros anteriores


if [ $# -ne 2 ]
then
  echo "Calling this script it must input two parameters."
  exit 1
fi

# Si filesdir no representa un directorio en el sistema de ficheros, sale con el valor de retorno 1 error e imprime las instrucciones

[ -d $1 ] || {
  echo "The dictory does not exist."
  exit 1
}

# Imprime el mensaje "El número de ficheros es X y el número de líneas coincidentes es Y" donde X es el número de ficheros
# en el directorio y todos los subdirectorios e Y es el número de líneas coincidentes encontradas en los respectivos ficheros,
# donde una línea coincidente se refiere a una línea que contiene searchstr (y también puede contener contenido adicional).

var_x=$(ls -1A $1 | wc -l)


var_y=$(find $1 -maxdepth 1 -type f -exec grep -woc $2 {} \; | awk '{sum += $1} END {print sum}')

echo "The number of files are $var_x and the number of matching lines are $var_y"

